class Case
  module Forms
    # A form object for an income history row
    class Income < ::Form
      # -- fields --
      field(:month, :string, presence: true)
      field(:amount, :string, presence: true)
    end

    # A form object for household case info
    class Household < ::Form
      use_entity_name!

      # -- props --
      prop(:case)

      # -- fields --
      # -- fields/dhs
      field(:mdhhs_number, :string, presence: true)

      # -- fields/household
      field(:household_size, :string, presence: true)
      field(:income_history, ListField.new(Income), presence: true, list: true)

      # -- lifetime --
      def initialize(kase, attrs = Household.default_params)
        @case = kase
        super(attrs)
      end

      # -- commands --
      def save
        if not valid?
          return false
        end
      end

      # -- queries --
      def self.default_params
        { income_history: [Income.new] }
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
