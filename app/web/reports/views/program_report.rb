module Reports
  module Views
    class ProgramReport < Report
      include ActionView::Helpers::TranslationHelper

      # -- constants --
      R = ::Program::Requirement

      # -- lifetime --
      def initialize(program, rows)
        @program = program
        super(rows)
      end

      # -- Report --
      def filename
        return "Cohere - #{@program.name} Report.csv"
      end

      protected def to_csv_headers
        headers = [
          "Client ID",
          "Date",
          "Wayne County",
          "First Name",
          "Last Name",
          "Residential Address",
          "City",
          "State",
          "Zip",
          "Cell Phone #",
          "Household Size",
          "Income Verification Type",
        ]

        if requirement?(R::HouseholdOwnership)
          headers.push(
            "Rent / Own",
          )
        end

        if requirement?(R::FoodDietaryRestrictions)
          headers.push(
            "Dietary Restrictions",
          )
        end

        if requirement?(R::SupplierAccountPresent)
          headers.concat([
            "Utility Company",
            "Account Number",
            "Arrears",
          ])
        end

        headers.push(
          "Award Amount",
        )

        return headers
      end

      protected def to_csv_row(r)
        values = [
          r.recipient_id,
          r.completed_date,
          r.wayne_county,
          r.first_name,
          r.last_name,
          r.street,
          r.city,
          r.state,
          r.zip,
          r.phone_number,
          r.household_size,
          r.household_proof_of_income,
        ]

        if requirement?(R::HouseholdOwnership)
          values.push(
            r.household_ownership,
          )
        end

        if requirement?(R::FoodDietaryRestrictions)
          values.push(
            r.dietary_restrictions,
          )
        end

        if requirement?(R::SupplierAccountPresent)
          values.concat([
            r.supplier_name,
            r.supplier_account_number,
            r.supplier_account_arrears,
          ])
        end

        values.push(
          r.benefit_amount,
        )

        return values
      end

      # -- helpers --
      private def requirement?(requirement)
        return @program.requirement?(requirement)
      end
    end
  end
end
