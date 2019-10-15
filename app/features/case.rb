class Case < ::Entity
  # -- props --
  prop(:id)
  prop(:recipient)
  prop(:enroller)
  prop(:status)
  prop(:updated_at)
  prop(:completed_at)

  # -- lifetime --
  def initialize(id:, recipient:, enroller:, status:, updated_at:, completed_at:)
    @id = id
    @recipient = recipient
    @enroller = enroller
    @status = status
    @updated_at = updated_at
    @completed_at = completed_at
  end

  # -- factories --
  def self.from_record(record)
    Case.new(
      id: record.id,
      recipient: Recipient.from_record(record.recipient),
      enroller: Enroller.from_record(record.enroller),
      status: record.status.to_sym,
      updated_at: record.updated_at,
      completed_at: record.completed_at
    )
  end
end
