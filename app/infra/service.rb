module Service
  extend ActiveSupport::Concern

  class_methods do
    # provide an accessor that returns a transient instance of this service
    def get
      return self.new
    end
  end
end
