module Cases
  module Forms
    class Contact < ApplicationForm
      # -- name --
      field(:first_name, :string, presence: true)
      field(:last_name, :string, presence: true)

      # -- phone --
      field(:phone_number, :string,
        presence: true, numericality: true, length: { is: 10 }
      )

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        if @model.nil?
          return
        end

        r = @model.recipient
        n = r.profile.name
        assign_defaults!(attrs, {
          first_name: n.first,
          last_name: n.last
        })

        p = r.profile.phone
        assign_defaults!(attrs, {
          phone_number: p.number
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
    end
  end
end
