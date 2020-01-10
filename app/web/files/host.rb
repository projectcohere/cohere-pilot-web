module Files
  module Host
    # If necessary, sets the file host for the current request.
    def self.set_current!
      storage = Rails.application.config.active_storage

      if storage.service == :local || storage.service == :test
        ActiveStorage::Current.host = ENV["HOST"]
      end
    end
  end
end
