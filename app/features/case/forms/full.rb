class Case
  module Forms
    # A form object for all the case info
    class Full < ::Form
      # -- props --
      prop(:case)
      prop(:inbound)
      prop(:opened)

      # -- lifetime --
      def initialize(kase)
        @case = kase
        @inbound = Inbound.new(kase)
        @opened = Opened.new(kase)
      end

      # -- commands --
      def save
      end

      # -- ActiveModel::Model --
      def id
        @case.id
      end

      def persisted?
        true
      end
    end
  end
end
