module Cases
  class View
    # -- props --
    attr(:case)

    # -- lifetime --
    def initialize(
      kase,
      enroller_repo: Enroller::Repo.get,
      supplier_repo: Supplier::Repo.get,
      document_repo: Document::Repo.get
    )
      @case = kase
      @enroller_repo = enroller_repo
      @supplier_repo = supplier_repo
      @document_repo = document_repo
    end

    # -- queries --
    def status
      @case.status.to_s.camelize
    end

    # -- queries/profile
    def recipient_name
      @case.recipient.profile.name
    end

    def address
      @case.recipient.profile.address.to_lines
    end

    def phone_number
      @case.recipient.profile.phone.number
    end

    # -- queries/account
    def account_number
      @case.account.number
    end

    def account_arrears
      @case.account.arrears_dollars
    end

    # -- queries/dhs-account
    def dhs_number
      @case.recipient.dhs_account.number
    end

    def household_size
      @case.recipient.dhs_account.household.size
    end

    def household_income
      @case.recipient.dhs_account.household.income_cents / 100.0
    end

    def fpl_percentage
      "#{@case.fpl_percentage}%"
    end

    # -- queries/documents
    def documents
      @document_repo.find_all_for_case(@case.id)
    end

    # -- queries/associations
    def supplier_name
      @supplier_repo.find(@case.supplier_id).name
    end

    def enroller_name
      @enroller_repo.find(@case.enroller_id).name
    end

    # -- queries/timestamps
    def updated_at
      @case.updated_at
    end
  end
end
