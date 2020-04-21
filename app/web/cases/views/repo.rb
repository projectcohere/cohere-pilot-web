module Cases
  module Views
    # This repo provides queries to retrieve Case "read models" ("views", "projections")
    # used to render Case UI.
    class Repo < ::Repo
      include Service
      include Authorization

      # -- lifetime --
      def initialize(scope)
        @scope = scope
      end

      # -- queries --
      # -- queries/detail
      def find_detail(id)
        case_rec = make_query(detail: true)
          .find(id)

        return self.class.map_detail(case_rec)
      end

      # -- queries/form
      def new_form(entity = nil, params: nil)
        return make_form(entity, params)
      end

      def edit_form(id, params: nil)
        case_rec = make_query(detail: true)
          .find(id)

        return make_form(case_rec, params)
      end

      private def make_form(entity_or_record, params)
        detail = if entity_or_record != nil
          self.class.map_detail(entity_or_record)
        end

        # extract case params and set action, if any
        attrs = {}
        if params != nil
          attrs = params.fetch(:case, {})
          attrs[:action] = %i[submit approve deny remove].find { |k| params.key?(k) }
        end

        # build a form that from permitted attrs
        form = Form.new(detail, attrs) do |subform|
          policy.permit?(:"edit_#{subform}")
        end

        return form
      end

      # -- queries/notification
      def find_notification(id)
        case_rec = Case::Record.find(id)
        return self.class.map_notification(case_rec)
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
        when Scope::Open
          q.incomplete.by_updated_date
        when Scope::Completed
          q.complete.by_completed_date
        else
          assert(false, "#{@scope} is not allowed for search")
        end

        return paginate(q, page)
      end

      def find_all_assigned(page:)
        case_query = make_query
          .incomplete
          .with_assigned_user(user.id.val)
          .by_updated_date

        return paginate(case_query, page)
      end

      def find_all_queued(page:)
        case_query = make_query
          .incomplete
          .with_no_assignment_for_partner(user_partner_id)
          .by_updated_date

        return paginate(case_query, page)
      end

      private def paginate(case_query, page)
        case_page = Pagy.new(count: case_query.count(:all), page: page)
        case_recs = case_query.offset(case_page.offset).limit(case_page.items)

        case_cells = case_recs.map do |r|
          self.class.map_cell(r, @scope, user_partner_id)
        end

        return case_page, case_cells
      end

      # -- queries/helpers
      private def make_query(detail: false, worker: false)
        q = Case::Record

        # inlcude associations
        q = q.includes(:program, :recipient, :enroller, :supplier, assignments: :user)
        if detail
          q = q.includes(documents: { file_attachment: :blob })
        end

        # filter by role
        q = case user_membership
        when Partner::Membership::Supplier
          q.for_supplier(user_partner_id)
        when Partner::Membership::Governor
          q.for_governor(user_partner_id)
        when Partner::Membership::Enroller
          q.for_enroller(user_partner_id)
        else
          q
        end

        return q
      end

      # -- mapping --
      # -- mapping/detail
      def self.map_detail(entity_or_record)
        if entity_or_record.is_a?(Case)
          return self.map_detail_from_entity(entity_or_record)
        else
          return self.map_detail_from_record(entity_or_record)
        end
      end

      def self.map_detail_from_record(r)
        return Detail.new(
          id: Id.new(r.id),
          status: r.status.to_sym,
          program: Program::Repo.map_record(r.program),
          supplier_id: r.supplier_id,
          supplier_name: r.supplier.name,
          supplier_account: Case::Repo.map_supplier_account(r),
          enroller_name: r.enroller.name,
          recipient_id: r.recipient_id,
          recipient_profile: Recipient::Repo.map_profile(r.recipient),
          recipient_household: Recipient::Repo.map_household(r.recipient),
          referrer: r.referred != nil,
          referred: r.referrer_id != nil,
          assignments: r.assignments.map { |r| Case::Repo.map_assignment(r) },
          documents: r.documents&.map { |r| Case::Repo.map_document(r) },
        )
      end

      def self.map_detail_from_entity(e)
        return Detail.new(
          id: e.id,
          status: e.status,
          program: e.program,
          supplier_id: e.supplier_id,
          supplier_name: e.supplier_id&.then { |id| find_partner_name(id) },
          supplier_account: e.supplier_account,
          enroller_name: find_partner_name(e.enroller_id),
          recipient_id: e.recipient.id.val,
          recipient_profile: e.recipient.profile,
          recipient_household: e.recipient.household,
          referrer: e.referrer?,
          referred: e.referred?,
          assignments: e.assignments,
          documents: e.documents,
        )
      end

      def self.find_partner_name(partner_id)
        return Partner::Record.select(:name).find(partner_id).name
      end

      # -- mapping/form
      def self.map_form(entity_or_record, attrs)
        return Form.new(
          entity_or_record != nil ? map_detail(entity_or_record) : nil,
          attrs
        )
      end

      # -- mapping/notification
      def self.map_notification(r)
        return Notification.new(
          id: Id.new(r.id),
          status: r.status.to_sym,
          recipient_name: Recipient::Repo.map_name(r.recipient),
          enroller_id: r.enroller_id,
        )
      end

      # -- mapping/contract
      def self.map_contract(e)
        return Contract.new(
          date: Date.today,
          recipient_profile: e.recipient.profile,
        )
      end

      # -- mapping/cell
      def self.map_cell(r, scope, partner_id)
        return Cell.new(
          scope: scope,
          id: Id.new(r.id),
          status: r.status.to_sym,
          new_activity: r.new_activity,
          program: Program::Repo.map_record(r.program),
          supplier_name: r.supplier.name,
          enroller_name: r.enroller.name,
          recipient_name: Recipient::Repo.map_name(r.recipient),
          assignee_email: find_assignee_email(r, partner_id),
          created_at: r.created_at,
          updated_at: r.updated_at,
        )
      end

      def self.find_assignee_email(r, partner_id)
        if partner_id == nil
          return nil
        end

        assignment = r.assignments.find do |r|
          r.partner_id == partner_id
        end

        return assignment&.user&.email
      end
    end
  end
end
