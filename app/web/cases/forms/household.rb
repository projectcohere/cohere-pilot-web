module Cases
  module Forms
    class Household < ApplicationForm
      # -- fields --
      field(:household_size, :string,
        numericality: { allow_blank: true },
        on: { submitted: { presence: true } }
      )

      field(:income, :string,
        numericality: { allow_blank: true },
        on: { submitted: { presence: true } }
      )

      field(:ownership, :string,
        on: { submitted: { presence: true } }
      )

      field(:is_primary_residence, :boolean)

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        h = @model.recipient.dhs_account&.household
        assign_defaults!(attrs, {
          household_size: h&.size&.to_s,
          income: h&.income_dollars&.to_s,
          ownership: h&.ownership,
          is_primary_residence: h&.is_primary_residence
        })
      end
    end
  end
end
