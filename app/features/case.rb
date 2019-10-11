class Case
  attr_reader(
    :recipient,
    :enroller,
    :updated_at,
    :completed_at
  )

  # -- lifetime --
  def initialize(recipient:, enroller:, updated_at:, completed_at:)
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
      recipient: Recipient.from_record(record.recipient),
      enroller: Enroller.from_record(record.enroller),
      updated_at: record.updated_at,
      completed_at: record.completed_at
    )
  end
end
