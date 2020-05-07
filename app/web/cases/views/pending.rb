module Cases
  module Views
    class Pending < ::Value
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
