module Cases
  module Forms
    class Household < ApplicationForm
      # -- fields --
      field(:dhs_number, :string,
        on: {
          submitted: { presence: true },
          completed: { presence: true },
        },
      )

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
        h = @model.recipient.household
        assign_defaults!(attrs, {
          dhs_number: h&.dhs_number,
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
        Recipient::Ownership.all.map do |o|
          [o.to_s.titlecase, o]
        end
      end

      def map_to_recipient_household
        Recipient::Household.new(
          dhs_number: dhs_number,
          size: size.to_i,
          income: Money.dollars(income),
          ownership: ownership.nil? ? Recipient::Ownership::Unknown : ownership,
          is_primary_residence: is_primary_residence.nil? ? true : is_primary_residence
        )
      end
    end
  end
end
