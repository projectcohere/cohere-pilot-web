module Cases
  module Forms
    class Food < ApplicationForm
      # -- fields --
      field(:dietary_restrictions, :boolean)

      # -- lifecycle --
      protected def initialize_attrs(attrs)
        if not @model.respond_to?(:food)
          assign_defaults!(attrs, dietary_restrictions: false)
          return
        end

        assign_defaults!(attrs, {
          dietary_restrictions: @model.food&.dietary_restrictions || false,
        })
      end

      # -- transformation --
      def map_to_food
        return Case::Food.new(
          dietary_restrictions: dietary_restrictions,
        )
      end
    end
  end
end
