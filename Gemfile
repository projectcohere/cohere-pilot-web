source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "~> 2.6.3"

gem "aws-sdk-s3", "~> 1.52", require: false
gem "bootsnap", ">= 1.4.2", require: false
gem "clearance", "~> 1.17"
gem "openssl", "~> 2.1"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 3.11"
gem "rails", "~> 6.0.0"
gem "sass-rails", "~> 5"
gem "sentry-raven", "~> 2.12"
gem "sidekiq", "~> 6.0"
gem "turbolinks", "~> 5"
gem "webpacker", "~> 4.0"

group :development do
  gem "letter_opener", "~> 1.7"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

group :development, :test do
  gem "dotenv-rails", "~> 2.7"
  gem "faker", "~> 2.6"
  gem "pry-rails", "~> 0.3.9"
  gem "pry-byebug"
  gem "pry-rescue", "~> 1.5"
  gem "awesome_print", "~> 1.8"
end

group :test do
  gem "vcr", "~> 5.0"
  gem "webmock", "~> 3.7"
end
