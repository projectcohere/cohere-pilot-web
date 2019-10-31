class Case < ::Entity
  # TODO: should this be generalized for the aggregate root?
  prop(:record, default: nil)

  # -- props --
  prop(:id)
  prop(:recipient)
  prop(:supplier)
  prop(:enroller)
  prop(:status)
  prop(:updated_at)
  prop(:completed_at)

  # -- lifetime --
  define_initialize!

  # -- factories --
  def self.from_record(r)
    Case.new(
      record: r,
      id: r.id,
      recipient: Recipient.from_record(r.recipient),
      supplier: Supplier.from_record(r.supplier),
      enroller: Enroller.from_record(r.enroller),
      status: r.status.to_sym,
      updated_at: r.updated_at,
      completed_at: r.completed_at
    )
  end
end
