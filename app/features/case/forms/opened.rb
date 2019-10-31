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
      def initialize(kase, attrs = {})
        @model = kase

        # set initial values from case
        r = kase.recipient
        assign_defaults!(attrs, {
          dhs_number: r.dhs_number
        })

        h = r.household
        assign_defaults!(attrs, {
          household_size: h&.size,
          income_history: h&.income_history&.map { |i|
            Income.new(
              amount: i.amount
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

        if @model.record.nil? || @model.recipient.record.nil?
          raise "case must be constructed from a db record!"
        end

        @model.record.transaction do
          household = @model.recipient.record.household
          if household.nil?
            household = Recipient::Household::Record.new
          end

          household.assign_attributes(
            size: household_size,
            income_history: income_history.map(&:attributes)
          )

          @model.recipient.record.update!(
            dhs_number: dhs_number,
            household: household
          )

          @model.record.pending!
        end

        true
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
