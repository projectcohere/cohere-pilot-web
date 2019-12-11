module Cases
  class SaveForm
    def initialize(form, case_repo: Case::Repo.get)
      @form = form
      @case_repo = case_repo
    end

    # -- command --
    def call
      # new_status = @form.status.to_sym

      # scope = case new_status
      # when Case::Status::Submitted, Case::Status::Approved, Case::Status::Denied
      #   :submitted
      # end

      if not @form.valid?
        return false
      end

      kase = @form.model
      kase.contribute_cohere_data(
        map_form_to_supplier_account,
        map_form_to_profile,
        map_form_to_dhs_account,
      )

      # sign the contract if necessary
      selected_contract = @form.details.selected_contract
      if not selected_contract.nil?
        kase.sign_contract(selected_contract)
      end

      # case new_status
      # when Case::Status::Submitted
      #   model.submit_to_enroller
      # when Case::Status::Removed
      #   model.remove_from_pilot
      # when Case::Status::Approved, Case::Status::Denied
      #   model.complete(status)
      # end

      @case_repo.save_all_fields_and_documents(kase)

      true
    end

    # -- queries --
    private def map_form_to_profile
      c = @form.contact
      a = @form.address

      Recipient::Profile.new(
        phone: Recipient::Phone.new(
          number: c.phone_number
        ),
        name: Recipient::Name.new(
          first: c.first_name,
          last: c.last_name,
        ),
        address: Recipient::Address.new(
          street: a.street,
          street2: a.street2,
          city: a.city,
          state: "MI",
          zip: a.zip
        )
      )
    end

    private def map_form_to_supplier_account
      a = @form.utility_account

      Case::Account.new(
        number: a.account_number,
        arrears_cents: (a.arrears.to_f * 100.0).to_i,
        has_active_service: a.has_active_service.nil? ? true : a.has_active_service
      )
    end

    private def map_form_to_dhs_account
      m = @form.mdhhs
      h = @form.household

      Recipient::DhsAccount.new(
        number: m.dhs_number,
        household: Recipient::Household.new(
          size: h.size.to_i,
          income_cents: (h.income.to_f * 100.0).to_i,
          ownership: h.ownership.nil? ? Recipient::Household::Ownership::Unknown : h.ownership,
          is_primary_residence: h.is_primary_residence.nil? ? true : h.is_primary_residence
        )
      )
    end
  end
end
