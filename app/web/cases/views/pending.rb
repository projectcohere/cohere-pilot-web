module Cases
  module Views
    # A Case read model for rendering an unsaved, new case
    class Pending < ::Value
      include Routing

      # -- props --
      prop(:temp_id)
      prop(:program)

      # -- queries --
      def id
        return Id::None
      end
    end
  end
end
