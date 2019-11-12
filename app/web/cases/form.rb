module Cases
  # A form object for all the case info
  class Form < ::ApplicationForm
    # -- fields --
    field(:status, :string)
    field(:signed_contract, :boolean)
    fields_from(:supplier, SupplierForm)
    fields_from(:opened, DhsForm)

    # -- lifetime --
    def initialize(
      kase,
      attrs = {},
      case_repo: Case::Repo.get,
      supplier_repo: Supplier::Repo.get,
      enroller_repo: Enroller::Repo.get,
      document_repo: Document::Repo.get
    )
      # set dependencies
      @case_repo = case_repo
      @supplier_repo = supplier_repo
      @enroller_repo = enroller_repo
      @document_repo = document_repo

      # set underlying model
      @model = kase

      # construct subforms
      @supplier = SupplierForm.new(
        kase,
        attrs.slice(SupplierForm.attribute_names)
      )

      @opened = DhsForm.new(
        kase,
        attrs.slice(DhsForm.attribute_names)
      )

      # set initial values from case
      c = kase
      assign_defaults!(attrs, {
        status: c.status.to_s
      })

      super(attrs)
    end

    # -- commands --
    def save
      if not valid?(submitted? ? :submitted : nil)
        return false
      end

      @model.update_supplier_account(supplier.map_to_supplier_account)
      @model.update_recipient_profile(supplier.map_to_recipient_profile)
      @model.attach_dhs_account(opened.map_to_dhs_account)

      if signed_contract
        @model.sign_contract
      end

      if submitted?
        @model.submit
      end

      @case_repo.save(@model)

      true
    end

    # -- commands/helpers
    private def submitted?
      status == "submitted"
    end

    # -- queries --
    def name
      @model.recipient.profile.name
    end

    def fpl_percentage
      @model.fpl_percentage
    end

    def enroller_name
      @enroller_repo.find(@model.enroller_id).name
    end

    def supplier_name
      @supplier_repo.find(@model.supplier_id).name
    end

    def documents
      @model.documents
    end

    def statuses
      [
        :opened,
        :pending,
        :submitted,
        :approved,
        :rejected
      ]
    end

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
