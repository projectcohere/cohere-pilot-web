class Recipient < ::Entity
  # TODO: should this be generalized for the aggregate root?
  attr_reader(:record)

  # -- props --
  prop(:id)
  prop(:name)
  prop(:phone_number)
  prop(:dhs_number)
  prop(:address)
  prop(:account)
  prop(:household)

  # -- lifetime --
  def initialize(
    record: nil,
    id:,
    name:,
    phone_number:,
    dhs_number: nil,
    address:,
    account:,
    household: nil
  )
    @record = record
    @id = id
    @name = name
    @phone_number = phone_number
    @dhs_number = dhs_number
    @address = address
    @account = account
    @household = household
  end

  # -- factories --
  def self.from_record(r)
    Recipient.new(
      record: r,
      id: r.id,
      phone_number: r.phone_number,
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
      account: r.account.then { |a|
        Account.new(
          number: a.number,
          arrears: a.arrears,
          supplier: a.supplier.then { |s|
            Supplier.new(
              id: s.id,
              name: s.name
            )
          }
        )
      },
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
