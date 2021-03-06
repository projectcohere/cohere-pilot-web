# A form model for an entity. It expects to be nested inside of the entity
# as a namespace.
class ApplicationForm
  # for form objects, it's useful to have attribute assignment and validation
  include ActiveModel::Model
  include ActiveModel::Attributes

  # -- attrs --
  attr(:model)

  # -- lifetime --
  def initialize(model = nil, attrs = {}, &permit)
    @model = model

    # whitelist attrs if permittable
    shape = self.class.params_shape(&permit)
    if attrs.respond_to?(:permit) && !attrs.permitted?
      attrs = attrs.permit(shape)
    end

    # filter list of permitted subforms
    sf_names = self.class.subform_map&.keys
    if sf_names != nil
      sf_names &= shape.last.keys
    end

    # extract nested attrs for permitted subforms
    sf_attrs = sf_names&.each_with_object({}) do |sf_name, memo|
      memo[sf_name] = attrs.delete(sf_name) || {}
    end

    # assign local attrs
    initialize_attrs(attrs)
    super(attrs)

    # create permitted subforms
    sf_attrs&.each do |sf_name, sf_attrs|
      sf_class = self.class.subform_map[sf_name]
      subform = sf_class.new(model, sf_attrs.stringify_keys)
      instance_variable_set("@#{sf_name}", subform)
    end
  end

  # -- lifecycle --
  protected def initialize_attrs(attrs)
  end

  # -- queries --
  def self.subform_map
    return @subform_map.freeze
  end

  # -- definition --
  def self.field(name, type, **validations)
    attribute(name, type)

    if validations.present?
      validates(name, validations)
    end
  end

  def self.subform(form_name, form_class)
    # add to list of subforms
    @subform_map ||= {}
    @subform_map[form_name] = form_class

    # declare attr
    attr(form_name)

    # validate the child form
    validates(form_name, child: true)
  end

  # -- forms --
  # -- forms/types
  class SymbolType < ActiveModel::Type::Value
    def cast_value(value)
      return value.to_sym
    end
  end

  ActiveModel::Type.register(:symbol, SymbolType)
  ActiveModel::Type.register(:object, ActiveModel::Type::Value)

  # -- forms/validators
  class ChildValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if value == nil
        return true
      end

      if not value.valid?(record.validation_context)
        record.errors.merge!(value.errors)
      end
    end
  end

  # -- queries --
  def self.params_shape(&permit)
    # find local form params
    shape = attribute_names.map(&:to_sym)

    # join subform params
    if subform_map != nil
      sf_shape = subform_map.each_with_object({}) do |(sf_name, sf_class), memo|
        if !block_given? || permit.(sf_name)
          memo[sf_name] = sf_class.params_shape
        end
      end

      shape.push(sf_shape)
    end

    return shape
  end

  # -- ActiveModel --
  # -- ActiveModel::Model
  def id
    return @model&.id
  end

  def persisted?
    return id.is_a?(Id) ? id&.val != nil : id != nil
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
