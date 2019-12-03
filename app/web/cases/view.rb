module Cases
  class View
    # -- props --
    attr(:case)

    # -- lifetime --
    def initialize(
      kase,
      enroller_repo: Enroller::Repo.get,
      supplier_repo: Supplier::Repo.get
    )
      @case = kase
      @enroller_repo = enroller_repo
      @supplier_repo = supplier_repo
    end

    # -- queries --
    def status
      @case.status.to_s.camelize
    end

    def approved?
      @case.status == :approved
    end

    # -- queries/profile
    def recipient_name
      profile.name
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
      account.number
    end

    def account_arrears
      "$#{account.arrears_dollars}"
    end

    private def account
      @case.account
    end

    # -- queries/dhs-account
    def dhs_number
      dhs_account&.number || "Unknown"
    end

    def household_size
      dhs_account&.household&.size || "Unknown"
    end

    def household_income
      income_dollars = dhs_account&.household&.income_dollars
      income_dollars.nil? ? "Unknown" : "$#{income_dollars}"
    end

    def fpl_percentage
      fpl_percentage = @case.fpl_percentage
      fpl_percentage.nil? ? "Unknown" : "#{fpl_percentage}%"
    end

    private def dhs_account
      @case.recipient.dhs_account
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
      @enroller_repo.find(@case.enroller_id).name
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
