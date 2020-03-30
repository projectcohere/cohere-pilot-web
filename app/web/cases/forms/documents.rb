module Cases
  module Forms
    class Documents < ApplicationForm
      # -- fields --
      field(:all, :object,
        on: {
          submitted: { presence: true },
          completed: { presence: true },
        },
      )

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          all: @model.documents,
        })
      end
    end
  end
end
