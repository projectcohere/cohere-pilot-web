assets = Rails.application.config.assets
assets.enabled = true
assets.version = "1.0"
assets.paths << Rails.root.join("node_modules")
assets.paths << Rails.root.join("app", "assets", "fonts")
