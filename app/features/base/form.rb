# A form model for an entity. It expects to be nested inside of the entity
# as a namespace.
class Form
  # -- definition --
  def self.prop(name)
    attr_reader(name)
  end

  # -- props --
  prop(:model)

  # -- fields --
  def self.field(name, type, *validations)
    attribute(name, type)
    validates(name, *validations) if validations.present?
  end

  def self.fields_from(form_name, form_class)
    prop(form_name)

    field_getters = form_class.attribute_names
    field_setters = field_getters.map { |name| "#{name}=" }

    delegate(*field_getters, to: form_name)
    delegate(*field_setters, to: form_name)
  end

  # -- fields/types
  class ListField < ActiveModel::Type::Value
    attr_reader(:form_type)

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
    def validate_each(record, attribute, value)
      if not value.all?(&:valid?)
        record.errors.add(attribute, :invalid, list: value)
      end
    end
  end

  # -- queries --
  def self.params_shape
    child_keys, fields = attribute_names.partition do |name|
      attribute_types[name].is_a?(ListField)
    end

    children = child_keys.each_with_object({}) do |name, memo|
      memo[name.to_sym] = attribute_types[name].form_type.params_shape
    end

    fields.map!(&:to_sym)
    fields << children if children.present?
    fields
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
    id != nil
  end

  # -- ActiveModel::Naming
  extend ActiveModel::Naming

  def self.use_entity_name!
    @use_entity_name = true
  end

  # a form normally uses its own name stripped of any namespacing.
  #
  # if `use_entity_name!` is called, the form returns the name of the nearest entity
  # in its module ancestry. this allows Rails helpers to deduce paths based on the
  # entity name (not sure if desireable)
  def self.model_name
    @_model_name ||= begin
      if self == ::Form
        return super
      end

      # normal forms
      if not @use_entity_name
        return ActiveModel::Name.new(self)
      end

      # entity-named forms
      parent_type = module_parent
      until parent_type < ::Entity || parent_type.nil?
        parent_type = parent_type.module_parent
      end

      env = ENV["RAILS_ENV"]
      if env == "development" || env == "test"
        if parent_type.nil?
          raise "#{self} must be nested in a subclass of Entity"
        end
      end

      parent_type.model_name
    end
  end

  protected

  # -- helpers --
  # a version of with_defaults! that overwrites nils
  def assign_defaults!(attrs, defaults)
    defaults.each do |key, value|
      if attrs[key].nil?
        attrs[key] = defaults[key]
      end
    end
  end
end
