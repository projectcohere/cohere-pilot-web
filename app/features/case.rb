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
end
