module Cases
  class DhsForm < ::ApplicationForm
    # -- fields --
    # -- fields/dhs
    field(:dhs_number, :string,
      on: { submitted: { presence: true } }
    )

    # -- fields/household
    field(:household_size, :string,
      numericality: { allow_blank: true },
      on: { submitted: { presence: true } }
    )

    field(:income, :string,
      numericality: { allow_blank: true },
      on: { submitted: { presence: true } }
    )

    field(:ownership, :string,
      on: { submitted: { presence: true } }
    )

    field(:is_primary_residence, :boolean)

    # -- lifetime --
    def initialize(model, attrs = {}, case_repo: Case::Repo.get)
      @case_repo = case_repo
      super(model, attrs)
    end

    protected def initialize_attrs(attrs)
      r = @model.recipient
      assign_defaults!(attrs, {
        dhs_number: r.dhs_account&.number
      })

      h = r.dhs_account&.household
      assign_defaults!(attrs, {
        household_size: h&.size&.to_s,
        income: h&.income_dollars&.to_s,
        ownership: h&.ownership,
        is_primary_residence: h&.is_primary_residence
      })
    end

    # -- commands --
    def save
      if not valid?
        return false
      end

      @model.attach_dhs_account(map_to_dhs_account)
      @case_repo.save_pending(@model)

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
          size: household_size.to_i,
          income_cents: (income.to_f * 100.0).to_i,
          ownership: ownership.nil? ? Recipient::Household::Ownership::Unknown : ownership,
          is_primary_residence: is_primary_residence.nil? ? true : is_primary_residence
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
      @model.documents.filter do |document|
        document.classification != :contract
      end
    end

    def wrap?
      false
    end

    # -- ApplicationForm --
    def self.entity_type
      Case
    end
  end
end
