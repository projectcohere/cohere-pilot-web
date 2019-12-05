module Cases
  # A form object for all the case info
  class Form < ::ApplicationForm
    # -- fields --
    field(:status, :string,
      inclusion: %w[opened pending submitted approved denied removed]
    )

    field(:supplier_id, :integer)
    field(:signed_contract, :boolean,
      on: { submitted: { presence: true } }
    )

    fields_from(:supplier, SupplierForm)
    fields_from(:dhs, DhsForm)

    # -- lifetime --
    def initialize(
      kase,
      attrs = {},
      case_repo: Case::Repo.get,
      supplier_repo: Supplier::Repo.get,
      enroller_repo: Enroller::Repo.get
    )
      # set dependencies
      @case_repo = case_repo
      @supplier_repo = supplier_repo
      @enroller_repo = enroller_repo

      # set underlying model
      @model = kase

      # construct subforms
      @supplier = SupplierForm.new(
        kase,
        attrs.slice(SupplierForm.attribute_names)
      )

      @dhs = DhsForm.new(
        kase,
        attrs.slice(DhsForm.attribute_names)
      )

      # set initial values from case
      c = kase
      assign_defaults!(attrs, {
        status: c.status.to_s,
        supplier_id: c.supplier_id,
        signed_contract: @model.signed_contract?
      })

      super(attrs)
    end

    # -- commands --
    def save(referrer: nil)
      scope = if submitted?
        :submitted
      elsif @model.referral?
        :referral
      end

      if not valid?(scope)
        return false
      end

      @model.update_supplier_account(supplier.map_to_supplier_account)
      @model.update_recipient_profile(supplier.map_to_recipient_profile)
      @model.attach_dhs_account(dhs.map_to_dhs_account)

      if signed_contract
        @model.sign_contract
      end

      case new_status
      when Case::Status::Submitted
        @model.submit_to_enroller
      when Case::Status::Removed
        @model.remove_from_pilot
      when Case::Status::Approved, Case::Status::Denied
        @model.complete(new_status)
      end

      if referrer.nil?
        @case_repo.save_all_fields_and_documents(@model)
      else
        @case_repo.save_all_fields_and_documents(@model, referrer)
      end

      true
    end

    # -- commands/helpers
    private def new_status
      @status_key ||= status.to_sym
    end

    private def submitted?
      new_status == Case::Status::Submitted || new_status == Case::Status::Approved || new_status == Case::Status::Denied
    end

    # -- queries --
    def name
      @model.recipient.profile.name
    end

    def fpl_percentage
      @model.fpl_percentage
    end

    def program_name
      @model.program.to_s.upcase
    end

    def enroller_name
      @enroller_repo.find(@model.enroller_id).name
    end

    def supplier_options
      @supplier_repo.find_all_by_program(@model.program).map do |s|
        [s.name.titlecase, s.id]
      end
    end

    def documents
      @model.documents
    end

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
