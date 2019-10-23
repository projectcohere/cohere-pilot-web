class Case
  module Forms
    # A form object for an income history row
    class Income < ::Form
      # -- fields --
      field(:amount, :string, presence: true)
      # deprecated: month is not used right now
      field(:month, :string)
    end

    # A form object for household case info
    class Opened < ::Form
      use_entity_name!

      # -- props --
      prop(:case)

      # -- fields --
      # -- fields/dhs
      field(:dhs_number, :string, presence: true)

      # -- fields/household
      field(:household_size, :string, presence: true)
      field(:income_history, ListField.new(Income), presence: true, list: true)

      # -- lifetime --
      def initialize(kase, attrs = {})
        @case = kase

        # set initial values from case
        r = kase.recipient
        h = r.household

        assign_defaults!(attrs, {
          dhs_number: r.dhs_number,
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

        if @case.record.nil? || @case.recipient.record.nil?
          raise "case must be constructed from a db record!"
        end

        # TODO: need pattern for performing mutations through domain objects
        # and then serializing and saving to db.
        @case.record.transaction do
          household = @case.recipient.record.household
          if household.nil?
            household = Recipient::Household::Record.new
          end

          household.assign_attributes(
            size: household_size,
            income_history: income_history.map(&:attributes)
          )

          @case.recipient.record.update!(
            dhs_number: dhs_number,
            household: household
          )

          @case.record.update!(
            status: :scorable
          )
        end
      end

      # -- queries --
      def address
        @case.recipient.address.to_lines
      end

      # -- ActiveModel::Model --
      def id
        @case.id
      end

      def persisted?
        true
      end
    end
  end
end
