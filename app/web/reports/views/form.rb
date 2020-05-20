module Reports
  module Views
    # A Report form object for specifying a report to generate
    class Form < ApplicationForm
      include Reports::Policy::Context::Shared
      include ActionView::Helpers::TranslationHelper

      # -- constants --
      Accounting = "accounting".freeze

      # -- fields --
      field(:report, :string, presence: true)
      field(:start_date, :date, presence: true)
      field(:end_date, :date, presence: true)

      # -- fields/validations
      validate(:check_date_order!)

      # -- lifetime --
      def initialize(model = nil, attrs: {}, program_repo: Program::Repo.get)
        @program_repo = program_repo
        super(model, attrs)
      end

      # -- commands --
      def check_date_order!
        if start_date == nil || end_date == nil
          return
        end

        if not end_date.after?(start_date)
          errors.add(:end_date, "must be after start date")
        end
      end

      # -- queries --
      def report_options
        options = {}

        if permit?(:create_internal)
          options[t("reports.internal.title")] = [
            [t("reports.internal.#{Accounting}"), Accounting]
          ]
        end

        if permit?(:create_programs)
          programs = @program_repo
            .find_all_by_partner(user_partner_id)

          options[t("reports.programs.title")] = programs.map do |program|
            [program.name, program.id]
          end
        end

        return options
      end

      # -- ActiveModel --
      def self.model_name
        return ActiveModel::Name.new(Reports, nil, "report")
      end
    end
  end
end
