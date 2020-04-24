module Service
  module Single
    extend ActiveSupport::Concern

    class_methods do
      # returns the single instance of the service
      def get
        return Service::Container.get(self)
      end
    end
  end
end
