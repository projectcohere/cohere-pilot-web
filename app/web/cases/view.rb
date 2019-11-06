module Cases
  class View
    # -- props --
    attr(:case)

    # -- lifetime --
    def initialize(
      kase,
      enrollers: Enroller::Repo.get,
      suppliers: Supplier::Repo.get,
      documents: Document::Repo.get
    )
      @case = kase
      @enrollers = enrollers
      @suppliers = suppliers
      @documents = documents
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
      @case.account.arrears
    end

    # -- queries/dhs-account
    def dhs_number
      @case.recipient.dhs_account.number
    end

    def household_size
      @case.recipient.dhs_account.household.size
    end

    def household_income
      @case.recipient.dhs_account.household.income
    end

    # -- queries/documents
    def documents
      @documents.find_for_case(@case.id)
    end

    # -- queries/associations
    def supplier_name
      @suppliers.find_one(@case.supplier_id).name
    end

    def enroller_name
      @enrollers.find_one(@case.enroller_id).name
    end

    # -- queries/timestamps
    def updated_at
      @case.updated_at
    end
  end
end
