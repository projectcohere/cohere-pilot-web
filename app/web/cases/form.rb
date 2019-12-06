module Cases
  # A form object for all the case info
  class Form < ::ApplicationForm
    # -- fields --
    field(:status, :string,
      inclusion: %w[opened pending submitted approved denied removed]
    )

    field(:supplier_id, :integer)
    field(:contract_variant, :integer,
      on: { submitted: { presence: true } }
    )

    fields_from(:supplier, SupplierForm)
    fields_from(:dhs, DhsForm)

    # -- lifetime --
    def initialize(
      kase,
      attrs = {},
      case_repo: Case::Repo.get,
      program_repo: Program::Repo.get,
      supplier_repo: Supplier::Repo.get,
      enroller_repo: Enroller::Repo.get
    )
      # set dependencies
      @case_repo = case_repo
      @program_repo = program_repo
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
        contract_variant: contracts.find_index { |c| c.variant == @model.contract_variant }
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

      # sign the contract if necessary
      if not contract_variant.nil?
        @model.sign_contract(contracts[contract_variant])
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
        [s.name, s.id]
      end
    end

    def contract_options
      contracts.map.with_index do |c, i|
        [name_from_contract_variant(c.variant), i]
      end
    end

    def documents
      @model.documents
    end

    # -- queries/helpers
    private def contracts
      @program_repo.find_by_name(@model.program).contracts
    end

    private def name_from_contract_variant(variant)
      case variant
      when Program::Contract::Meap
        "MEAP"
      when Program::Contract::Wrap3h
        "WRAP ($300)"
      when Program::Contract::Wrap1k
        "WRAP ($1000)"
      end
    end

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
