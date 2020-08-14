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
end

ActiveStorage::Blob.prepend(DemoExt::ActiveStorage::Blob)
