module Reports
  module Views
    # A Report form object for specifying a report to generate
    class Form < ApplicationForm
      include Reports::Policy::Context::Shared
      include ActionView::Helpers::TranslationHelper

      # -- fields --
      field(:report, :string, presence: true)
      field(:start_date, :date, presence: true)
      field(:end_date, :date, presence: true)

      # -- fields/validations
      validate(:check_date_order!)

      # -- lifetime --
      def initialize(model = nil, attrs = {}, program_repo: Program::Repo.get)
        @program_repo = program_repo
        super(model, attrs)
      end

      # -- commands --
      def check_date_order!
        if not end_date.after?(start_date)
          errors.add(:end_date, "must be after start date")
        end
      end

      # -- queries --
      def report_options
        options = []

        if permit?(:list_accounting)
          options << [t("reports.form.accounting"), :accounting]
        end

        if permit?(:list_programs)
          @program_repo.find_all_by_partner(user_partner_id).each do |program|
            options << [program.name, program.id]
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
