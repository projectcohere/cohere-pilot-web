class Case
  class Factory
    def create_inbound(inbound, supplier_id, enroller_id)
      Case::Record.transaction do
        new_recipient = Recipient::Record.create!(
          first_name: inbound.first_name,
          last_name: inbound.last_name,
          phone_number: inbound.phone_number,
          street: inbound.street,
          street2: inbound.street2,
          city: inbound.city,
          state: inbound.state,
          zip: inbound.zip
        )

        new_account = Recipient::Account::Record.create!(
          number: inbound.account_number,
          arrears: inbound.arrears,
          recipient: new_recipient,
          supplier_id: supplier_id
        )

        new_case = Case::Record.create!(
          recipient: new_recipient,
          supplier_id: supplier_id,
          enroller_id: enroller_id
        )
      end
    end
  end
end
