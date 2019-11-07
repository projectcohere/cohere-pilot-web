web: ./bin/puma -C config/puma.rb
worker: ./bin/sidekiq -c 1 -q default -q mailers
release: DISABLE_DATABASE_ENVIRONMENT_CHECK=1 ./bin/rails db:schema:load
