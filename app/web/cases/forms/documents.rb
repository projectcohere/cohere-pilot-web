module Cases
  module Forms
    class Documents < ApplicationForm
      # -- fields --
      field(:all, :object, presence: { on: :submitted })

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          all: @model.documents,
        })
      end
    end
  end
end
