module Service
  module Singleton
    extend ActiveSupport::Concern

    # using .included instead of #included for now.
    #
    # it seems like we're running into some sort of race condition between
    # CurrentAttributes, the #included hook, and autoloading where singleton
    # accessors are sometimes not defined when Service::Container's class (or
    # the classes of objects it stores?) reloads.
    def self.included(service)
      # define singleton storage on the container
      Service::Container.singleton(service)
    end

    class_methods do
      # provide an accessor that returns the singleton instance
      def get
        return Service::Container.get(self)
      end
    end
  end
end
