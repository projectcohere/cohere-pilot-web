module Cases
  module Forms
    class Household < ApplicationForm
      include Case::Policy::Context::Shared
      include ActionView::Helpers::TranslationHelper

      # -- fields --
      field(:proof_of_income, :symbol, presence: true)

      field(:size, :string, numericality: { allow_blank: true },
        presence: {
          on: :submitted,
        },
      )

      field(:dhs_number, :string,
        presence: {
          on: :submitted,
          if: -> { permit?(:edit_dhs_number) }
        }
      )

      field(:income, :string, numericality: { allow_blank: true },
        presence: {
          on: :submitted,
          if: -> { permit?(:edit_household_income) },
        },
      )

      field(:ownership, :symbol,
        inclusion: {
          in: Recipient::Ownership.valid.map(&:key),
          if: -> { permit?(:edit_household_ownership) },
        },
      )

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        if not @model.respond_to?(:household)
          return
        end

        h = @model.household
        assign_defaults!(attrs, {
          dhs_number: h&.dhs_number,
          size: h&.size&.to_s,
          proof_of_income: h&.proof_of_income,
          income: h&.income&.dollars,
          ownership: h&.ownership&.to_sym,
        })
      end

      # -- sanitization --
      def income=(value)
        super(value&.gsub(/[^\d\.]+/, ""))
      end

      # -- queries/options
      def proof_of_income_options
        return Recipient::ProofOfIncome.map do |o|
          [t("recipient.proof_of_income.#{o}"), o.key]
        end
      end

      def ownership_options
        return Recipient::Ownership.map do |o|
          [t("recipient.ownership.#{o}"), o.key]
        end
      end

      # -- transformation --
      def map_to_household
        return Recipient::Household.new(
          size: size.to_i,
          proof_of_income: Recipient::ProofOfIncome.from_key(proof_of_income),
          dhs_number: dhs_number,
          income: Money.dollars(income),
          ownership: Recipient::Ownership.from_key(ownership),
        )
      end

      # -- Case::Policy::Context --
      alias :case :model
    end
  end
end
