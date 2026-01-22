# Be sure to restart your server when you modify this file.

# Path within public/ where assets are compiled to
Rails.application.config.assets.prefix = "/assets/content-block-manager"

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Add engines to the assets load path
Dir.glob(Rails.root.join("engines/**/assets/*")).each do |path|
  Rails.application.config.assets.paths << path
end

Dir.glob(Rails.root.join("engines/**/assets/config/manifest.js")).each do |path|
  Rails.application.config.assets.precompile << path
end
