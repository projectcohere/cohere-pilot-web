class Case
  # A form object and entity factory for inbound cases
  class Inbound < ::Form
    # -- props --
    # -- props/name
    prop(:first_name, :string, presence: true)
    prop(:last_name, :string, presence: true)

    # -- props/phone
    prop(:phone_number, :string, presence: true)

    # -- props/address
    prop(:street, :string, presence: true)
    prop(:street2, :string)
    prop(:city, :string, presence: true)
    prop(:state, :string, presence: true)
    prop(:zip, :string, presence: true)

    # -- props/utility-account
    prop(:account_number, :string, presence: true)
    prop(:arrears, :string, presence: true)

    # -- commands --
    def save(supplier_id, enroller_id)
      if not valid?
        return false
      end

      Case::Record.transaction do
        new_recipient = Recipient::Record.create!(
          first_name: first_name,
          last_name: last_name,
          phone_number: phone_number,
          street: street,
          street2: street2,
          city: city,
          state: state,
          zip: zip
        )

        new_account = Recipient::Account::Record.create!(
          number: account_number,
          arrears: arrears,
          recipient: new_recipient,
          supplier_id: supplier_id
        )

        new_case = Case::Record.create!(
          recipient: new_recipient,
          supplier_id: supplier_id,
          enroller_id: enroller_id
        )
      end

      true
    end
  end
end
