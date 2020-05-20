module Reports
  module Views
    # This repo provides queries to retrieve Report "read models" ("views", "projections")
    # used to render Report UI.
    class Repo < ::Repo
      include Service
      include Reports::Policy::Context::Shared

      # -- lifetime --
      def initialize(program_repo: Program::Repo.get)
        @program_repo = program_repo
      end

      # -- queries --
      # -- queries/form
      def new_form(params: nil)
        attrs = params&.fetch(:report, {}) || {}
        return Form.new(nil, attrs: attrs)
      end

      # -- queries/csvs
      def make_report(form)
        if form.report == Form::Accounting
          return make_accounting_report(form)
        else
          return make_program_report(form, form.report)
        end
      end

      private def make_accounting_report(form)
        case_recs = find_cases
          .with_completion_between(form.start_date, form.end_date)

        return AccountingReport.new(
          case_recs.map { |r| self.class.map_row(r) },
        )
      end

      private def make_program_report(form, program_id)
        case_recs = find_cases
          .where(program_id: program_id)
          .with_completion_between(form.start_date, form.end_date)

        return ProgramReport.new(
          @program_repo.find(program_id),
          case_recs.map { |r| self.class.map_row(r) },
        )
      end

      private def find_cases
        case_query = Case::Record
          .join_recipient
          .join_supplier
          .approved
          .for_role(user_role, user_partner_id)

        return case_query
      end

      # -- mapping --
      def self.map_row(r)
        return Report::Row.new(
          recipient_id: r.recipient_id,
          completed_at: r.completed_at,
          supplier_name: r.supplier&.name,
          profile: Recipient::Repo.map_profile(r.recipient),
          household: Recipient::Repo.map_household(r.recipient),
          supplier_account: Case::Repo.map_supplier_account(r),
          food: Case::Repo.map_food(r),
          benefit: Case::Repo.map_benefit(r),
        )
      end
    end
  end
end
