module Support
  module Settings
    def set_working_hours!
      settings = ::Settings.get
      settings.working_hours = true
      settings.save
    end
  end
end

ActiveSupport::TestCase.include(Support::Settings)
