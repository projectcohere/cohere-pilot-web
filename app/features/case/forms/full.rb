class Case
  module Forms
    # A form object for all the case info
    class Full < ::Form
      # -- props --
      prop(:case)

      # -- lifetime --
      def initialize(kase)
        @case = kase
      end

      # -- commands --
      def save
      end
    end
  end
end
