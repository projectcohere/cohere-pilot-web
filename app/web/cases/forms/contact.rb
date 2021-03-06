module Cases
  module Forms
    class Contact < ApplicationForm
      # -- fields --
      field(:first_name, :string, presence: true)
      field(:last_name, :string, presence: true)
      field(:phone_number, :string, presence: true, numericality: true, length: { is: 10 })

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        if not @model.respond_to?(:profile)
          return
        end

        r = @model&.profile
        n = r&.name
        assign_defaults!(attrs, {
          first_name: n&.first,
          last_name: n&.last
        })

        p = r&.phone
        assign_defaults!(attrs, {
          phone_number: p&.number
        })
      end

      # -- santiziation --
      def first_name=(value)
        super(value&.strip&.titlecase)
      end

      def last_name=(value)
        super(value&.strip&.titlecase)
      end

      def phone_number=(value)
        super(value&.gsub(/\D+/, "")) # strip non-numeric characters
      end

      # -- queries --
      def map_to_recipient_phone
        return Phone.new(
          number: phone_number,
        )
      end

      def map_to_recipient_name
        return Name.new(
          first: first_name,
          last: last_name,
        )
      end
    end
  end
end
