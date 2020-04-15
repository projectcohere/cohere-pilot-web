module Cases
  # This repo provides queries to retrieve Case "read models" ("views", "projections")
  # used to render Case UI.
  class ViewRepo < ::Repo
    include Service

    def initialize(scope, user_repo: User::Repo.get)
      @scope = scope
      @user_repo = user_repo
    end

    # -- queries --
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
        .with_no_assignment_for_partner(role.partner_id)
        .by_updated_date

      return paginate(case_query, page)
    end

    # -- queries/helpers
    private def make_query
      q = Case::Record

      # inlcude associations
      q = q.includes(:recipient, :enroller, :supplier, assignments: :user)

      # filter by role
      q = case role.membership
      when Partner::Membership::Supplier
        q.for_supplier(role.partner_id)
      when Partner::Membership::Governor
        q.for_governor
      when Partner::Membership::Enroller
        q.for_enroller(role.partner_id)
      else
        q
      end

      return q
    end

    private def paginate(case_query, page)
      case_page = Pagy.new(count: case_query.count(:all), page: page)
      case_recs = case_query.offset(case_page.offset).limit(case_page.items)

      case_cells = case_recs.map do |r|
        self.class.make_cell(r, @scope, role.partner_id)
      end

      return case_page, case_cells
    end

    private def user
      return @user_repo.find_current
    end

    private def role
      return user.role
    end

    # -- mapping --
    def self.make_cell(r, scope, partner_id)
      return Views::Cell.new(
        scope: scope,
        id: r.id,
        status: r.status,
        has_new_activity: r.has_new_activity,
        program: Program::Name.from_key(r.program),
        recipient_name: make_name(r.recipient),
        supplier_name: r.supplier.name,
        enroller_name: r.enroller.name,
        assignee_email: find_assignee(r, partner_id)&.email,
        created_at: r.created_at,
        updated_at: r.updated_at,
      )
    end

    def self.make_name(r)
      return Views::Name.new(
        first: r.first_name,
        last: r.last_name,
      )
    end

    def self.find_assignee(r, partner_id)
      if partner_id == nil
        return nil
      end

      assignment = r.assignments.find do |r|
        r.partner_id == partner_id
      end

      return assignment&.user
    end
  end
end
