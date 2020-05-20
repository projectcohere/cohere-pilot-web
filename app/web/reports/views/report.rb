require "csv"

module Reports
  module Views
    class Report
      # -- lifetime --
      def initialize(rows)
        @rows = rows
      end

      # -- queries --
      def filename
        return "report.csv"
      end

      def to_csv
        csv_options = {
          headers: to_csv_headers,
          write_headers: true,
        }

        return CSV.generate(csv_options) do |csv|
          @rows.each do |r|
            csv << to_csv_row(r)
          end
        end
      end

      # -- queries/abstract
      protected def to_csv_headers
        return []
      end

      protected def to_csv_row(c)
        return []
      end

      # -- children --
      class Row < ::Value
        include ActionView::Helpers::TranslationHelper

        # -- props --
        prop(:recipient_id)
        prop(:supplier_name)
        prop(:profile)
        prop(:household)
        prop(:supplier_account)
        prop(:food)
        prop(:benefit)
        prop(:completed_at)

        # -- queries --
        def completed_date
          return @completed_at.to_date.to_s
        end

        # -- queries/contact
        def phone_number
          return @profile.phone.number
        end

        def first_name
          return name.first
        end

        def last_name
          return name.last
        end

        def street
          street = address.street

          if address.street2 != nil
            street += " #{address.street2}"
          end

          return street
        end

        def wayne_county
          return "TRUE"
        end

        delegate(:city, :state, :zip, to: :address)

        # -- queries/contact/helpers
        private def name
          return @profile.name
        end

        private def address
          return @profile.address
        end

        # -- queries/household
        def household_size
          return @household.size
        end

        def household_proof_of_income
          return t("recipient.proof_of_income.#{@household.proof_of_income.key}")
        end

        def household_ownership
          return t("recipient.ownership.#{@household.ownership.key}")
        end

        # -- queries/account
        def supplier_account_number
          return @supplier_account.number
        end

        def supplier_account_arrears
          return format_money(@supplier_account.arrears)
        end

        # -- queries/food
        def dietary_restrictions
          return @food.dietary_restrictions ? "TRUE" : "FALSE"
        end

        # -- queries/benefit
        def benefit_amount
          return format_money(@benefit)
        end

        # -- queries/helpers
        private def format_money(money)
          return money != nil ? "$#{money.dollars}" : ""
        end
      end
    end
  end
end
