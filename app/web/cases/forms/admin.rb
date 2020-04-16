module Cases
  module Forms
    class Admin < ApplicationForm
      # -- fields --
      field(:status, :symbol, presence: true)

      # -- lifecycle --
      def initialize(model, attrs = {})
        super(model, attrs)
      end

      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          status: @model.status_key,
        })
      end

      # -- queries/view
      def status_options
        return Case::Status.all.map do |s|
          [s.capitalize, s]
        end
      end
    end
  end
end
