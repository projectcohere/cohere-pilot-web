class Entity
  include ::Initializable

  # -- equality --
  def ==(other)
    self.class == other.class && self.id == other.id
  end

  # -- ActiveModel --
  # we minimally conform to ActiveModel so that we can use our entities
  # with various Rails helpers like link_to

  # -- ActiveModel::naming
  extend ActiveModel::Naming

  # -- ActiveModel::Conversion
  include ActiveModel::Conversion

  # -- ActiveModel::Model
  # i don't think we want the other modules ActiveModel::Model includes
  def persisted?
    @id != nil
  end

  # -- debugging --
  def inspect
    return "<#{self.class.name}:#{object_id} id=#{@id}>"
  end
end
