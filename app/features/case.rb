class Case < Entity
  prop(:id)
  prop(:recipient)
  prop(:enroller)
  prop(:updated_at)
  prop(:completed_at)

  # -- lifetime --
  def initialize(id:, recipient:, enroller:, updated_at:, completed_at:)
    @id = id
    @recipient = recipient
    @enroller = enroller
    @updated_at = updated_at
    @completed_at = completed_at
  end

  # -- queries --
  def incomplete?
    @completed_at.nil?
  end

  # -- factories --
  def self.from_record(record)
    Case.new(
      id: record.id,
      recipient: Recipient.from_record(record.recipient),
      enroller: Enroller.from_record(record.enroller),
      updated_at: record.updated_at,
      completed_at: record.completed_at
    )
  end

  # -- experiments
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
