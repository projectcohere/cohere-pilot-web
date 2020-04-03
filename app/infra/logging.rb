module Logging
  # -- queries --
  def log
    if Sidekiq.logger.level == Logger::FATAL
      return Rails.logger
    else
      return Sidekiq.logger
    end
  end
end
