require "sidekiq/testing"

SidekiqUniqueJobs.configure do |config|
  config.enabled = false
end
