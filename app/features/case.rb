class Case
  # -- lifetime --
  def initialize(recipient:, completed:)
    @recipient = recipient
    @completed = completed
  end

  # -- status --
  def incomplete?
    !@completed
  end

  # -- recipient --
  attr_reader(:recipient)

  # -- factories --
  def self.from_record(record)
    Case.new(
      recipient: Recipient.from_record(record.recipient),
      completed: record.completed_at != nil
    )
  end
end
