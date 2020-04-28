module Cases
  module Forms
    class Address < ApplicationForm
      # -- fields --
      field(:street, :string, presence: true)
      field(:street2, :string)
      field(:city, :string, presence: true)
      field(:zip, :string, presence: true, numericality: true )
      field(:geography, :boolean, presence: true)

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        if not @model.respond_to?(:recipient_profile)
          return
        end

        a = @model.recipient_profile.address
        assign_defaults!(attrs, {
          street: a.street,
          street2: a.street2,
          city: a.city,
          zip: a.zip,
          geography: true,
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

      # -- queries --
      def map_to_recipient_address
        return ::Address.new(
          street: street,
          street2: street2,
          city: city,
          state: "MI",
          zip: zip,
        )
      end
    end
  end
end
