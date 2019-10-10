class Case
  # -- lifetime --
  def initialize(recipient:, updated_at:, completed_at:)
    @recipient = recipient
    @updated_at = updated_at
    @completed_at = completed_at
  end

  # -- status --
  attr_reader(:updated_at)
  attr_reader(:completed_at)

  def incomplete?
    @completed_at.nil?
  end

  # -- recipient --
  attr_reader(:recipient)

  # -- factories --
  def self.from_record(record)
    Case.new(
      recipient: Recipient.from_record(record.recipient),
      updated_at: record.updated_at,
      completed_at: record.completed_at
    )
  end
end
