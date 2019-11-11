module Cases
  class DhsForm < ::ApplicationForm
    # -- fields --
    # -- fields/dhs
    field(:dhs_number, :string,
      on: { submitted: { presence: true } }
    )

    # -- fields/household
    field(:household_size, :string,
      numericality: true,
      on: { submitted: { presence: true } }
    )

    field(:income, :string,
      numericality: true,
      on: { submitted: { presence: true } }
    )

    # -- lifetime --
    def initialize(
      kase,
      attrs = {},
      case_repo: Case::Repo.get,
      document_repo: Document::Repo.get
    )
      # set dependencies
      @case_repo = case_repo
      @document_repo = document_repo

      # set underlying model(s)
      @model = kase

      # set initial values from case
      r = kase.recipient
      assign_defaults!(attrs, {
        dhs_number: r.dhs_account&.number
      })

      h = r.dhs_account&.household
      assign_defaults!(attrs, {
        household_size: h&.size,
        income: h&.income
      })

      super(attrs)
    end

    # -- commands --
    def save
      if not valid?
        return false
      end

      @model.attach_dhs_account(map_to_dhs_account)
      @case_repo.save_dhs_account(@model)

      true
    end

    # -- commands/sanitization
    def income=(value)
      value&.gsub!(/[^\d\.]+/, "")
      super
    end

    # -- commands/helpers
    def map_to_dhs_account
      Recipient::DhsAccount.new(
        number: dhs_number,
        household: Recipient::Household.new(
          size: household_size,
          income: income
        )
      )
    end

    # -- queries --
    def name
      @model.recipient.profile.name
    end

    def address
      @model.recipient.profile.address.to_lines
    end

    def documents
      @document_repo.find_all_for_case(@model.id)
    end

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
