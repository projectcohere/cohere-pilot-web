module Cases
  class View
    include ActionView::Helpers::DateHelper

    # -- props --
    attr(:case)
    attr(:scope)

    # -- lifetime --
    def initialize(
      kase,
      scope = nil,
      partner_repo: Partner::Repo.get
    )
      @case = kase
      @scope = scope
      @partner_repo = partner_repo
    end

    # -- queries --
    def id
      return @case.id
    end

    def status_key
      return @case.status
    end

    # -- queries/routing
    def list_path
      return urls.cases_path
    end

    def detail_path
      return @scope&.completed? ? show_path : edit_path
    end

    def show_path
      return urls.case_path(@case)
    end

    def edit_path
      return urls.edit_case_path(@case)
    end

    def assign_path
      return urls.case_assignments_path(@case)
    end

    private def urls
      return Rails.application.routes.url_helpers
    end

    # -- queries/labels
    def back_label
      return "Back to Cases"
    end

    def assign_label
      return "Assign to Me"
    end

    def created_label
      return "Opened #{created_at.to_date}"
    end

    def updated_label
      return "Updated #{time_ago_in_words(updated_at)} ago"
    end

    # -- queries/activity
    def new_activity?
      return @case.new_activity?
    end

    # -- queries/details
    def status
      return @case.status.to_s.capitalize
    end

    def program_name
      return @case.program.key.to_s.upcase
    end

    def wrap?
      return @case.wrap?
    end

    def approved?
      return @case.status == Case::Status::Approved
    end

    # -- queries/profile
    def recipient_name
      return profile.name
    end

    def recipient_first_name
      return profile.name.first
    end

    def address
      return profile.address.lines
    end

    def phone_number
      return profile.phone.number
    end

    private def profile
      return @case.recipient.profile
    end

    # -- queries/account
    def account_number
      return supplier_account.number
    end

    def account_arrears
      return "$#{supplier_account.arrears.dollars}"
    end

    def active_service?
      return supplier_account.active_service?
    end

    private def supplier_account
      return @case.supplier_account
    end

    # -- queries/dhs-account
    def dhs_number
      return household&.dhs_number || "Unknown"
    end

    def household_size
      return household&.size || "Unknown"
    end

    def household_income
      income_dollars = household&.income&.dollars
      return income_dollars.nil? ? "Unknown" : "$#{income_dollars}"
    end

    def ownership
      return household&.ownership&.to_s&.titlecase
    end

    def primary_residence?
      return household&.primary_residence?
    end

    def household_fpl_percent
      fpl_percent = @case.recipient.household&.fpl_percent
      return fpl_percent.nil? ? nil : "#{fpl_percent}%"
    end

    private def household
      return @case.recipient.household
    end

    # -- queries/documents
    def documents
      return @case.documents
    end

    # -- queries/partners
    def supplier_name
      return @partner_repo.find(@case.supplier_id).name
    end

    def enroller_name
      return @partner_repo.find(@case.enroller_id).name
    end

    # -- queries/referral
    def can_make_referral?
      return @case.can_make_referral?
    end

    def referral_program
      return @case.referral_program
    end

    def referral_program_name
      return case @case.referral_program
      when Program::Name::Meap
        "MEAP"
      when Program::Name::Wrap
        "WRAP"
      end
    end

    # -- queries/assignment
    def shows_assign?
      return @scope.queued? && assignee == nil
    end

    def assignee
      email = @case.selected_assignment&.user_email
      return email&.split("@")&.first
    end

    def assignments
      return @case.assignments
    end

    # -- queries/timestamps
    def created_at
      return @case.updated_at
    end

    def updated_at
      return @case.updated_at
    end
  end
end
