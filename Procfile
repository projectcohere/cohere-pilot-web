web: ./bin/puma -C config/puma.rb
worker: ./bin/sidekiq -c 1 -q default -q mailers
release: ./bin/rails db:schema:load
