module Cases
  module Forms
    class Mdhhs < ApplicationForm
      # -- fields --
      field(:dhs_number, :string,
        on: { submitted: { presence: true } }
      )

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        a = @model.recipient.dhs_account
        assign_defaults!(attrs, {
          dhs_number: a&.number
        })
      end
    end
  end
end
