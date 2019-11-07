module Cases
  # A form object for all the case info
  class Form < ::ApplicationForm
    # -- fields --
    field(:status, :string)
    fields_from(:inbound, InboundForm)
    fields_from(:opened, OpenedForm)

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
      @inbound = InboundForm.new(
        kase,
        attrs.slice(InboundForm.attribute_names)
      )

      @opened = OpenedForm.new(
        kase,
        attrs.slice(OpenedForm.attribute_names)
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

      @model.update_supplier_account(inbound.map_to_supplier_account)
      @model.update_recipient_profile(inbound.map_to_recipient_profile)
      @model.attach_dhs_account(opened.map_to_dhs_account)

      if submitted?
        @model.submit()
      end

      @cases.save_all_fields(@model)

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
