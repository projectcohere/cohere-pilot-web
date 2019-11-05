class Case
  module Forms
    # A form object for all the case info
    class Full < ::Form
      use_entity_name!

      # -- fields --
      field(:status, :string)
      fields_from(:inbound, Inbound)
      fields_from(:opened, Opened)

      # -- lifetime --
      def initialize(
        kase,
        attrs = {},
        cases: Case::Repo.new,
        suppliers: Supplier::Repo.new,
        enrollers: Enroller::Repo.new
      )
        # set dependencies
        @cases = cases
        @suppliers = suppliers
        @enrollers = enrollers

        # set underlying model
        @model = kase

        # construct subforms
        @inbound = Inbound.new(
          kase,
          attrs.slice(Inbound.attribute_names),
          cases: cases,
          suppliers: suppliers,
          enrollers: enrollers
        )

        @opened = Opened.new(
          kase,
          attrs.slice(Opened.attribute_names),
          cases: cases
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

        @model.update_supplier_account(inbound.map_supplier_account)
        @model.update_recipient_profile(inbound.map_recipient_profile)
        @model.attach_dhs_account(opened.map_dhs_account)

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
        @enroller_name ||= begin
          enroller = @enrollers.find_one(@model.enroller_id)
          enroller.name
        end
      end

      def supplier_name
        @supplier_name ||= begin
          supplier = @suppliers.find_one(@model.supplier_id)
          supplier.name
        end
      end

      def documents
        @model.recipient.documents
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
    end
  end
end
