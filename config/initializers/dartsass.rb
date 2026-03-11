Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css",
}

Rails.application.config.dartsass.build_options << " --quiet-deps --silence-deprecation=import --silence-deprecation=mixed-decls"
