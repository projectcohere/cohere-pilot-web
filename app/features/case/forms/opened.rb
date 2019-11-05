class Case
  module Forms
    # A form object for an income history row
    class Income < ::Form
      # -- fields --
      field(:amount, :string,
        on: { submitted: { presence: true } }
      )

      # deprecated: month is not used right now
      field(:month, :string)
    end

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

      field(:income_history, ListField.new(Income),
        on: { submitted: { presence: true, list: true } }
      )

      # -- lifetime --
      def initialize(
        kase,
        attrs = {},
        cases: Case::Repo.new
      )
        # set dependencies
        @cases = cases

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
          income_history: h&.income&.map { |i|
            Income.new(
              amount: i
            )
          }
        })

        # stub income history if necessary
        assign_defaults!(attrs, {
          income_history: [Income.new]
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

        # @model.record.transaction do
        #   household = @model.recipient.record.household
        #   if household.nil?
        #     household = Recipient::Household::Record.new
        #   end

        #   household.assign_attributes(
        #     size: household_size,
        #     income_history: income_history.map(&:attributes)
        #   )

        #   @model.recipient.record.update!(
        #     dhs_number: dhs_number,
        #     household: household
        #   )

        #   @model.record.pending!
        # end

        true
      end

      # -- commands/helpers
      def map_dhs_account
        Recipient::DhsAccount.new(
          number: dhs_number,
          household: Recipient::Household.new(
            size: household_size,
            income: income_history[0]&.amount
          )
        )
      end

      # -- queries --
      def name
        @model.recipient.name
      end

      def address
        @model.recipient.address.to_lines
      end

      def documents
        @model.recipient.documents
      end
    end
  end
end
