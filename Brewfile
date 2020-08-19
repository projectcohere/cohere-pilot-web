# need most recent postgres for tools (psql) and to build "pg" gem
brew "postgresql"

# underlying database; it's the app db
brew "postgresql@11"

# in-memory store; required for sidekiq
brew "redis"

# js package manager; required for webpack
brew "yarn"

# pdf generator; required to create contracts
cask "wkhtmltopdf"

# image tools; required by ActiveStorage to transform images
brew "imagemagick"

# pdf previewer; required by ActiveStorage to generate PDF previews
brew "poppler"

# tool for deploying demo site
brew "netlify-cli"

# selenium chromedriver; required for headless system tests
cask "chromedriver"

# chrome browser; required for chromedriver
cask "google-chrome"
