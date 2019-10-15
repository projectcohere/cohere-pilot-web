# A form model for an entity. It expects to be nested inside of the entity
# as a namespace.
class Form
  # -- definition --
  def self.prop(name, type, **validations)
    attribute(name, type)

    if not validations.empty?
      validates(name, validations)
    end
  end

  # -- ActiveModel --
  # for form objects, it's helpful to have full attribute assignment and
  # validation
  include ActiveModel::Model
  include ActiveModel::Attributes

  # -- ActiveModel::naming
  extend ActiveModel::Naming

  # return our entity's name so that Rails helpers can deduce the right
  # paths for the corresponding entity
  def self.model_name
    if self == ::Form
      return super
    end

    env = ENV["RAILS_ENV"]
    if env == "development" || env == "test"
      if not module_parent < Entity
        raise "#{self} must be nested inside of a subclass of Entity!"
      end
    end

    module_parent.model_name
  end
end
