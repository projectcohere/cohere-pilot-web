module Service
  module Singleton
    extend ActiveSupport::Concern

    included do
      # define the singleton storage on the container
      Service::Container.singleton(self)
    end

    class_methods do
      # provide an accessor that returns the singleton instance of this service
      def get
        return Service::Container.get(self)
      end
    end
  end
end
