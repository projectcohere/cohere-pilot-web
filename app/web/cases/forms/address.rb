module Cases
  module Forms
    class Address < ApplicationForm
      # -- fields --
      field(:street, :string, presence: true)
      field(:street2, :string)
      field(:city, :string, presence: true)
      field(:zip, :string,
        presence: true, numericality: true
      )

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        a = @model.recipient.profile.address
        assign_defaults!(attrs, {
          street: a.street,
          street2: a.street2,
          city: a.city,
          zip: a.zip,
        })
      end

      # -- sanitization --
      def first_name=(value)
        super(value&.strip&.titlecase)
      end

      def last_name=(value)
        super(value&.strip&.titlecase)
      end

      def street=(value)
        super(value&.strip&.titlecase)
      end

      def street2=(value)
        super(value&.strip&.titlecase)
      end

      def city=(value)
        super(value&.strip&.titlecase)
      end
    end
  end
end
