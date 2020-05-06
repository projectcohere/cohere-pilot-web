module Cases
  module Events
    class DidViewSourceForm < ::Value
      # -- props --
      prop(:temp_id)

      # -- factories --
      def self.from_entity(kase)
        DidViewSourceForm.new(
          temp_id: kase.id,
        )
      end
    end
  end
end
