class Case
  module Forms
    # A form object for inbound cases
    class Inbound < ::Form
      use_entity_name!

      # -- fields --
      # -- fields/name
      field(:first_name, :string, presence: true)
      field(:last_name, :string, presence: true)

      # -- fields/phone
      field(:phone_number, :string, presence: true)

      # -- fields/address
      field(:street, :string, presence: true)
      field(:street2, :string)
      field(:city, :string, presence: true)
      field(:state, :string, presence: true)
      field(:zip, :string, presence: true)

      # -- fields/utility-account
      field(:account_number, :string, presence: true)
      field(:arrears, :string, presence: true)

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
end
