# A form model for an entity. It expects to be nested inside of the entity
# as a namespace.
class ApplicationForm
  # -- attrs --
  attr(:model)

  # -- fields --
  def self.field(name, type, **validations)
    attribute(name, type)

    if validations.present?
      # add context-dependent validations
      by_context = validations.delete(:on)
      by_context&.each do |context, validations|
        validations[:on] = context
        validates(name, validations)
      end

      # add context-independent validations
      if validations.present?
        validates(name, validations)
      end
    end
  end

  def self.fields_from(form_name, form_class)
    # add to list of subforms
    @subform_classes ||= []
    @subform_classes << form_class

    # declare attr
    attr(form_name)

    # delegate attributes to the child form
    field_getters = form_class.attribute_names
    field_setters = field_getters.map { |name| "#{name}=" }

    delegate(*field_getters, to: form_name)
    delegate(*field_setters, to: form_name)

    # validate the child form
    validates(form_name, child: true)
  end

  # -- fields/types
  class ListField < ActiveModel::Type::Value
    attr(:form_type)

    def initialize(form_type)
      @form_type = form_type
    end

    def cast(value)
      values = value.respond_to?(:values) ? value.values : value
      values.map do |value|
        value.is_a?(@form_type) ? value : @form_type.new(value)
      end
    end
  end

  # -- fields/validators
  class ListValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, list)
      if not list.all? { |v| v.valid?(record.validation_context) }
        record.errors.add(attribute, :invalid, list: list)
      end
    end
  end

  class ChildValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if not value.valid?(record.validation_context)
        record.errors.merge!(value.errors)
      end
    end
  end

  # -- queries --
  def self.params_shape
    params = []
    nested_params = {}

    # find local form params
    f_nested_param_names, f_params = attribute_names.partition do |name|
      attribute_types[name].is_a?(ListField)
    end

    f_nested_params = f_nested_param_names.each_with_object({}) do |name, memo|
      memo[name.to_sym] = attribute_types[name].form_type.params_shape
    end

    # join local form params
    params += f_params.map(&:to_sym)
    nested_params.merge!(f_nested_params)

    # join subform params
    @subform_classes&.each do |sf_class|
      sf_params = sf_class.params_shape

      # merge any nested params from the subforms
      if sf_params.present? && sf_params.last.is_a?(Hash)
        sf_nested_params = sf_params.pop
        nested_params.merge!(sf_nested_params)
      end

      # append its leaf params
      params += sf_params
    end

    # finally, add nested params if there are any
    params << nested_params if nested_params.present?
    params
  end

  # -- ActiveModel --
  # -- ActiveModel::Model
  # for form objects, it's helpful to have full attribute assignment and
  # validation
  include ActiveModel::Model
  include ActiveModel::Attributes

  def id
    @model&.id
  end

  def persisted?
    id&.val != nil
  end

  # -- ActiveModel::Naming
  extend ActiveModel::Naming

  # a form normally uses its own name stripped of any namespacing.
  #
  # if `.entity_type` is defined, the form returns the name of that entity, allowing
  # Rails helpers to infer paths based on the entity's name.
  def self.model_name
    @_model_name ||= begin
      if self == ::ApplicationForm
        super
      elsif respond_to?(:entity_type)
        entity_type.model_name
      else
        ActiveModel::Name.new(self)
      end
    end
  end

  protected

  # -- helpers --
  # a version of with_defaults! that overwrites nils
  def assign_defaults!(attrs, defaults)
    defaults.each do |key, value|
      key = key.to_s
      if attrs[key].nil?
        attrs[key] = value
      end
    end
  end
end
