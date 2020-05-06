module Cases
  module Forms
    class Admin < ApplicationForm
      include ActionView::Helpers::TranslationHelper

      # -- fields --
      field(:status, :symbol, presence: true)

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        assign_defaults!(attrs, {
          status: @model.status,
        })
      end

      # -- queries/view
      def status_options
        return Case::Status.map do |s|
          [t("case.status.#{s}"), s.key]
        end
      end

      # -- transformation --
      def map_to_status
        return Case::Status.from_key(status)
      end
    end
  end
end
