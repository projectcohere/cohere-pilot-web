module Cases
  class View
    # -- props --
    attr(:case)

    # -- lifetime --
    def initialize(
      kase,
      partner_repo: Partner::Repo.get,
      supplier_repo: Supplier::Repo.get
    )
      @case = kase
      @partner_repo = partner_repo
      @supplier_repo = supplier_repo
    end

    # -- queries --
    def id
      @case.id
    end

    def status
      @case.status.to_s.camelize
    end

    def program_name
      @case.program.to_s.upcase
    end

    def wrap?
      @case.wrap?
    end

    def approved?
      @case.status == :approved
    end

    def has_new_activity
      @case.has_new_activity
    end

    # -- queries/profile
    def recipient_name
      profile.name
    end

    def recipient_first_name
      profile.name.first
    end

    def address
      profile.address.to_lines
    end

    def phone_number
      profile.phone.number
    end

    private def profile
      @case.recipient.profile
    end

    # -- queries/account
    def account_number
      supplier_account.number
    end

    def account_arrears
      "$#{supplier_account.arrears_dollars}"
    end

    def active_service?
      supplier_account.has_active_service
    end

    private def supplier_account
      @case.supplier_account
    end

    # -- queries/dhs-account
    def dhs_number
      dhs_account&.number || "Unknown"
    end

    def household_size
      household&.size || "Unknown"
    end

    def household_income
      income_dollars = household&.income_dollars
      income_dollars.nil? ? "Unknown" : "$#{income_dollars}"
    end

    def ownership
      household&.ownership&.to_s&.titlecase
    end

    def primary_residence?
      household&.is_primary_residence
    end

    def fpl_percentage
      fpl_percentage = @case.fpl_percentage
      fpl_percentage.nil? ? nil : "#{fpl_percentage}%"
    end

    private def dhs_account
      @case.recipient.dhs_account
    end

    private def household
      dhs_account&.household
    end

    # -- queries/documents
    def documents
      @case.documents
    end

    # -- queries/associations
    def supplier_name
      @supplier_repo.find(@case.supplier_id).name
    end

    def enroller_name
      @partner_repo.find(@case.enroller_id).name
    end

    # -- queries/timestamps
    def created_at
      @case.updated_at
    end

    def updated_at
      @case.updated_at
    end
  end
end
