module Cases
  module Forms
    class Household < ApplicationForm
      # -- fields --
      field(:size, :string,
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

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        h = @model.recipient.dhs_account&.household
        assign_defaults!(attrs, {
          size: h&.size&.to_s,
          income: h&.income_dollars&.to_s,
          ownership: h&.ownership,
          is_primary_residence: h&.is_primary_residence
        })
      end

      # -- sanitization --
      def income=(value)
        super(value&.gsub(/[^\d\.]+/, ""))
      end

      # -- queries --
      def ownership_options
        Recipient::Household::Ownership.all.map do |o|
          [o.to_s.titlecase, o]
        end
      end

      def map_to_recipient_household
        Recipient::Household.new(
          size: size.to_i,
          income_cents: (income.to_f * 100.0).to_i,
          ownership: ownership.nil? ? Recipient::Household::Ownership::Unknown : ownership,
          is_primary_residence: is_primary_residence.nil? ? true : is_primary_residence
        )
      end
    end
  end
end
