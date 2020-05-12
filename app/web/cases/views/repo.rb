module Cases
  module Views
    # This repo provides queries to retrieve Case "read models" ("views", "projections")
    # used to render Case UI.
    class Repo < ::Repo
      include Service
      include Case::Policy::Context

      # -- lifetime --
      def initialize(scope = nil, program_repo: Program::Repo.get)
        @scope = scope
        @program_repo = program_repo
      end

      # -- queries --
      # -- queries/program-picker
      def new_program_picker(partner_id)
        programs = @program_repo
          .find_all_by_partner(partner_id)

        return self.class.map_program_picker(nil, programs)
      end

      def program_picker(id)
        case_rec = make_query(detail: true)
          .find(id)

        programs = @program_repo
          .find_all_available_by_recipient(case_rec.recipient_id)

        return self.class.map_program_picker(case_rec, programs)
      end

      # -- queries/detail
      def find_detail(id)
        case_rec = make_query(detail: true)
          .find(id)

        return self.class.map_detail_from_record(case_rec)
      end

      # -- queries/forms
      def new_form(temp_id, program_id, params: nil)
        if temp_id.blank?
          raise ActiveRecord::RecordNotFound
        end

        program = @program_repo
          .find(program_id)

        return make_form(
          self.class.map_pending(temp_id, program),
          params,
        )
      end

      def edit_form(id, params: nil)
        case_rec = make_query(detail: true)
          .find(id)

        return make_form(
          self.class.map_detail_from_record(case_rec),
          params,
        )
      end

      def note_form(id, params: nil)

      end

      def referral_form(entity, params: nil)
        return make_form(
          self.class.map_detail_from_entity(entity),
          params,
        )
      end

      private def make_form(model, params)
        # extract action, if any
        action = Action.find { |a| params&.key?(a.key) }
        # extract attrs, if any
        attrs = params&.fetch(:case, {}) || {}

        # build a form with permitted attrs
        form = policy.with_case(model) do |p|
          Form.new(model, action, attrs) do |subform|
            p.permit?(:"edit_#{subform}")
          end
        end

        return form
      end

      # -- queries/cells
      def find_all_for_search(search = "", page:)
        q = make_query

        # apply search
        q = case search
        when /^(\+1)?((\s|\d|[-\(\)])+)$/ # is phone-number-like
          q.with_phone_number($2.gsub(/\s|[-\(\)]+/, ""))
        when /^.+$/ # is non-empty
          q.with_recipient_name(search)
        else
          q
        end

        # filter by page scope
        q = case @scope
        when Scope::All
          q.by_updated_date
        when Scope::Active
          q.active.by_updated_date
        when Scope::Archived
          q.archived.by_completed_date
        else
          assert(false, "#{@scope} is not allowed for search")
        end

        return find_cells(q, page)
      end

      def find_all_assigned(page:)
        case_query = make_query
          .active
          .with_assigned_user(user.id.val)
          .by_updated_date

        return find_cells(case_query, page)
      end

      def find_all_queued(page:)
        case_query = make_query
          .active
          .with_no_assignment_for_role(user_role)
          .by_updated_date

        return find_cells(case_query, page)
      end

      private def find_cells(case_query, page)
        q = case_query
        q = q.visible

        case_page = Pagy.new(count: q.count(:all), page: page)
        case_recs = q.offset(case_page.offset).limit(case_page.items)

        case_cells = case_recs.map do |r|
          self.class.map_cell(r, @scope, find_role_assignment_rec(r))
        end

        return case_page, case_cells
      end

      private def find_role_assignment_rec(case_rec)
        assignment_rec = case_rec.assignments.find do |r|
          r.role == user_role.to_s && r.partner_id == user_partner_id
        end

        return assignment_rec
      end

      # -- queries/helpers
      private def make_query(detail: false, worker: false)
        q = Case::Record

        # inlcude associations
        q = q.includes(:program, :recipient, :enroller, :supplier, assignments: :user)
        if detail
          q = q.includes(notes: :user, documents: { file_attachment: :blob })
        end

        # filter by role
        q = case user_role
        when Role::Source
          q.for_source(user_partner_id)
        when Role::Governor
          q.for_governor(user_partner_id)
        when Role::Enroller
          q.for_enroller(user_partner_id)
        else
          q
        end

        return q
      end

      # -- mapping --
      # -- mapping/program-picker
      def self.map_program_picker(r, programs)
        return ProgramPicker.new(
          id: r != nil ? Id.new(r.id) : Id.new(SecureRandom.base58),
          recipient_id: r&.recipient_id,
          recipient_name: r&.recipient&.then { |r| Recipient::Repo.map_name(r) },
          programs: programs,
        )
      end

      # -- mapping/pending
      def self.map_pending(temp_id, program)
        return Pending.new(
          temp_id: Id.new(temp_id),
          program: program,
        )
      end

      # -- mapping/detail
      def self.map_detail_from_record(r)
        return Detail.new(
          id: Id.new(r.id),
          status: Case::Status.from_key(r.status),
          condition: Case::Condition.from_key(r.condition),
          program: Program::Repo.map_record(r.program),
          supplier_name: r.supplier&.name,
          supplier_account: Case::Repo.map_supplier_account(r),
          enroller_name: r.enroller.name,
          recipient_id: r.recipient_id,
          profile: Recipient::Repo.map_profile(r.recipient),
          household: Recipient::Repo.map_household(r.recipient),
          assignments: r.assignments.map { |r| Case::Repo.map_assignment(r) },
          notes: r.notes.by_most_recent.map { |r| Case::Repo.map_note(r) },
          documents: r.documents&.map { |r| Case::Repo.map_document(r) },
        )
      end

      def self.map_detail_from_entity(e)
        return Detail.new(
          id: e.id,
          status: e.status,
          condition: e.condition,
          program: e.program,
          supplier_name: e.supplier_account&.supplier_id&.then { |i| find_partner_name(i) },
          supplier_account: e.supplier_account,
          enroller_name: find_partner_name(e.enroller_id),
          recipient_id: e.recipient.id.val,
          profile: e.recipient.profile,
          household: e.recipient.household,
          assignments: e.assignments,
          notes: e.notes,
          documents: e.documents,
        )
      end

      def self.find_partner_name(partner_id)
        return Partner::Record.select(:name).find(partner_id).name
      end

      # -- mapping/contract
      def self.map_contract(e)
        return Contract.new(
          date: Date.today,
          profile: e.recipient.profile,
        )
      end

      # -- mapping/cell
      def self.map_cell(r, scope, assignment = nil)
        return Cell.new(
          scope: scope,
          id: Id.new(r.id),
          status: Case::Status.from_key(r.status),
          condition: Case::Condition.from_key(r.condition),
          new_activity: r.new_activity,
          program: Program::Repo.map_record(r.program),
          supplier_name: r.supplier&.name,
          enroller_name: r.enroller.name,
          recipient_name: Recipient::Repo.map_name(r.recipient),
          assignee_email: assignment&.user&.email,
          created_at: r.created_at,
          updated_at: r.updated_at,
        )
      end
    end
  end
end
