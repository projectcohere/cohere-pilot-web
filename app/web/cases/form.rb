module Cases
  # A form object for all the case info
  class Form < ::ApplicationForm
    # -- fields --
    field(:status, :string)
    fields_from(:supplier, SupplierForm)
    fields_from(:opened, DhsForm)

    # -- lifetime --
    def initialize(
      kase,
      attrs = {},
      cases: Case::Repo.get,
      suppliers: Supplier::Repo.get,
      enrollers: Enroller::Repo.get,
      documents: Document::Repo.get
    )
      # set dependencies
      @cases = cases
      @suppliers = suppliers
      @enrollers = enrollers
      @documents = documents

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

      if submitted?
        @model.submit()
      end

      @cases.save(@model)

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

    def enroller_name
      @enrollers.find(@model.enroller_id).name
    end

    def supplier_name
      @suppliers.find(@model.supplier_id).name
    end

    def documents
      @documents.find_all_for_case(@model.id)
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
