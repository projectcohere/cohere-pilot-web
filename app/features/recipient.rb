class Recipient < ::Entity
  # TODO: should this be generalized for the aggregate root?
  attr_reader(:record)

  # -- props --
  prop(:id)
  prop(:name)
  prop(:dhs_number)
  prop(:address)
  prop(:household)

  # -- lifetime --
  def initialize(
    record: nil,
    id:,
    dhs_number: nil,
    name:,
    address:,
    household: nil
  )
    @record = record
    @id = id
    @name = name
    @dhs_number = dhs_number
    @address = address
    @household = household
  end

  # -- factories --
  def self.from_record(r)
    Recipient.new(
      record: r,
      id: r.id,
      dhs_number: r.dhs_number,
      name: Name.new(
        first: r.first_name,
        last: r.last_name
      ),
      address: Address.new(
        street: r.street,
        street2: r.street2,
        city: r.city,
        state: r.state,
        zip: r.zip
      ),
      household: r.household&.then { |h|
        Household.new(
          size: h.size,
          income_history: h.income_history.map { |a|
            Income.new(**a.symbolize_keys)
          }
        )
      }
    )
  end
end
