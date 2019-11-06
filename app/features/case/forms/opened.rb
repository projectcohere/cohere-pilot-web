class Case
  module Forms
    # A form object for household case info
    class Opened < ::Form
      use_entity_name!

      # -- fields --
      # -- fields/dhs
      field(:dhs_number, :string,
        on: { submitted: { presence: true } }
      )

      # -- fields/household
      field(:household_size, :string,
        on: { submitted: { presence: true } }
      )

      field(:income, :string,
        on: { submitted: { presence: true } }
      )

      # -- lifetime --
      def initialize(
        kase,
        attrs = {},
        cases: Case::Repo.get,
        documents: Document::Repo.get
      )
        # set dependencies
        @cases = cases
        @documents = documents

        # set underlying model(s)
        @model = kase

        # set initial values from case
        r = kase.recipient
        assign_defaults!(attrs, {
          dhs_number: r.dhs_account&.number
        })

        h = r.dhs_account&.household
        assign_defaults!(attrs, {
          household_size: h&.size,
          income: h&.income
        })

        super(attrs)
      end

      # -- commands --
      def save
        if not valid?
          return false
        end

        @model.attach_dhs_account(map_dhs_account)
        @cases.save_dhs_account(@model)

        true
      end

      # -- commands/helpers
      def map_dhs_account
        Recipient::DhsAccount.new(
          number: dhs_number,
          household: Recipient::Household.new(
            size: household_size,
            income: income
          )
        )
      end

      # -- queries --
      def name
        @model.recipient.profile.name
      end

      def address
        @model.recipient.profile.address.to_lines
      end

      def documents
        @documents.find_all_for_case(@model.id)
      end
    end
  end
end
