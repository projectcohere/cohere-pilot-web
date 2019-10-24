class Case
  module Forms
    # A form object for all the case info
    class Full < ::Form
      use_entity_name!

      # -- props --
      prop(:case)

      # -- fields --
      fields_from(:inbound, Inbound)
      fields_from(:opened, Opened)

      # -- lifetime --
      def initialize(kase, attrs = {})
        @model = kase
        @inbound = Inbound.new(kase, attrs.slice(Inbound.attribute_names))
        @opened = Opened.new(kase, attrs.slice(Opened.attribute_names))
        super(attrs)
      end

      # -- commands --
      def save
      end

      # -- queries --
      def name
        @model.recipient.name
      end
    end
  end
end
