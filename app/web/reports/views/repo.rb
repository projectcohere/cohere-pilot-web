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
      def new_form
        return Form.new
      end
    end
  end
end
