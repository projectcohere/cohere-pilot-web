module Cases
  module Forms
    class Household < ApplicationForm
      include ActionView::Helpers::TranslationHelper

      # -- fields --
      field(:size, :string,
        numericality: { allow_blank: true },
        on: { submitted: { presence: true } }
      )

      field(:proof_of_income, :symbol,
        presence: true,
      )

      field(:dhs_number, :string,
        on: {
          submitted: { presence: true },
          completed: { presence: true },
        },
      )

      field(:income, :string,
        numericality: { allow_blank: true },
        on: { submitted: { presence: true } }
      )

      field(:ownership, :string,
        on: { submitted: { presence: true } }
      )

      field(:primary_residence, :boolean)

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        if not @model.respond_to?(:recipient_household)
          return
        end

        h = @model.recipient_household
        assign_defaults!(attrs, {
          dhs_number: h&.dhs_number,
          size: h&.size&.to_s,
          proof_of_income: h&.proof_of_income,
          income: h&.income&.dollars&.to_s,
          ownership: h&.ownership,
          primary_residence: h&.primary_residence?
        })
      end

      # -- sanitization --
      def income=(value)
        super(value&.gsub(/[^\d\.]+/, ""))
      end

      # -- queries --
      def proof_of_income_options
        return Recipient::ProofOfIncome.values.map do |o|
          [t("recipient.proof_of_income.#{o.key}"), o.key]
        end
      end

      def ownership_options
        return Recipient::Ownership.values.map do |o|
          [o.to_s.titlecase, o]
        end
      end

      def map_to_recipient_household
        return Recipient::Household.new(
          size: size.to_i,
          proof_of_income: Recipient::ProofOfIncome.from_key(proof_of_income),
          dhs_number: dhs_number,
          income: Money.dollars(income),
          ownership: ownership.nil? ? Recipient::Ownership::Unknown : ownership,
          primary_residence: primary_residence.nil? ? true : primary_residence
        )
      end
    end
  end
end
