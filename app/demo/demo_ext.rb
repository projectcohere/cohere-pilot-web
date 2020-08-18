module DemoExt
  module ActiveStorage
    module Blob
      # redirect all service urls to static file storage
      def service_url
        return "#{ENV["HOST"]}/storage/#{filename}"
      end

      # pretend like variants don't exist
      def representation(**kwargs)
        return self
      end

      def processed
        return self
      end
    end
  end

  module ActionDispatch
    module Routing
      def route_for(name, *args)
        if name == :rails_blob && args[0].is_a?(ActiveStorage::Blob)
          return args[0].service_url
        end

        return super(name, *args)
      end
    end
  end
end

ActiveStorage::Blob.prepend(DemoExt::ActiveStorage::Blob)
ActiveStorage::Attachment.prepend(DemoExt::ActiveStorage::Blob)
ActionDispatch::Routing::UrlFor.prepend(DemoExt::ActionDispatch::Routing)
