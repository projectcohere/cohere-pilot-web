module Cases
  module Views
    class Read
      include ::Initializable

      # -- debugging --
      def inspect
        return "<#{self.class.name}:#{object_id} id=#{@id}>"
      end
    end
  end
end
