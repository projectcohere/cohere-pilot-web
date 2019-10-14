class Entity
  class << self
    alias_method(:prop, :attr_reader)
  end

  # -- experiments --
  # TODO: this seems like all we need to do for entities to be passed
  # to helpers expecting a nameable type like link_to
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  # this is normally from ActiveModel::Model, but i don't think we want
  # its other included modules
  def persisted?
    @id != nil
  end
end
