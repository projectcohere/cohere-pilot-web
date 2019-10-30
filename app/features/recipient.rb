class Recipient < ::Entity
  # TODO: should this be generalized for the aggregate root?
  prop(:record, default: nil)

  # -- props --
  prop(:id)
  prop(:name)
  prop(:phone_number)
  prop(:dhs_number, default: nil)
  prop(:address)
  prop(:account)
  prop(:household, default: nil)
  prop(:documents, default: [])
  props_end!

  # -- commands --
  def add_documents_from_message(message)
    message.attachments.each do |attachment|
      @documents << Document.new(source_url: attachment.url)
    end
  end

  # -- queries --
  def new_documents
    @documents.filter { |d| d.id.nil? }
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
