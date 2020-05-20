module Reports
  module Views
    class AccountingReport < Report
      # -- Report --
      def filename
        return "Cohere - Accouting Report.csv"
      end

      protected def to_csv_headers
        return []
      end

      protected def to_csv_row(r)
        return []
      end
    end
  end
end
