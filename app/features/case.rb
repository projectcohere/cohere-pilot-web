class Case < ::Entity
  # TODO: should this be generalized for the aggregate root?
  attr_reader(:record)

  # -- props --
  prop(:id)
  prop(:recipient)
  prop(:enroller)
  prop(:status)
  prop(:updated_at)
  prop(:completed_at)

  # -- lifetime --
  def initialize(record: nil, id:, recipient:, enroller:, status:, updated_at:, completed_at:)
    @record = record
    @id = id
    @recipient = recipient
    @enroller = enroller
    @status = status
    @updated_at = updated_at
    @completed_at = completed_at
  end

  # -- factories --
  def self.from_record(r)
    Case.new(
      record: r,
      id: r.id,
      recipient: Recipient.from_record(r.recipient),
      enroller: Enroller.from_record(r.enroller),
      status: r.status.to_sym,
      updated_at: r.updated_at,
      completed_at: r.completed_at
    )
  end
end
