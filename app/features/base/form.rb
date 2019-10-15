# A form model for an entity. It expects to be nested inside of the entity
# as a namespace.
class Form
  # -- ActiveModel --
  # we minimally conform to ActiveModel so that we can use our entities
  # with various Rails helpers like link_to

  # -- ActiveModel::naming
  extend ActiveModel::Naming

  # return our entity's name so that Rails helpers can deduce the right
  # paths for the corresponding entity
  def self.model_name
    if ENV["RAILS_ENV"] == "development"
      unless module_parent < Entity
        raise "#{self} must be nested inside of a subclass of Entity!"
      end
    end

    module_parent.model_name
  end

  # -- ActiveModel::Conversion
  include ActiveModel::Conversion

  # -- ActiveModel::Model
  # i don't think we want the other modules ActiveModel::Model includes
  def persisted?
    @id != nil
  end
end
