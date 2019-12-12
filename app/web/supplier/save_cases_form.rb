class Supplier
  class SaveCasesForm < ::ApplicationForm
    # -- lifetime --
    def initialize(
      form,
      case_repo: Case::Repo.get,
      enroller_repo: Enroller::Repo.get,
      supplier_repo: Supplier::Repo.get
    )
      @form = form
      @case_repo = case_repo
      @enroller_repo = enroller_repo
      @supplier_repo = supplier_repo
    end

    # -- command --
    def call
      if not @form.valid?
        return false
      end

      # open a new case for the recipient
      enroller = @enroller_repo.find_default
      supplier = @supplier_repo.find_current

      new_case = supplier.open_case(enroller,
        profile: map_form_to_profile,
        account: map_form_to_supplier_account,
      )

      @case_repo.save_opened(new_case)

      true
    end

    # -- command/helpers
    private def map_form_to_supplier_account
      a = @form.supplier_account

      Case::Account.new(
        number: a.account_number,
        arrears_cents: (a.arrears.to_f * 100.0).to_i,
        has_active_service: a.has_active_service.nil? ? true : a.has_active_service
      )
    end

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
  end
end
