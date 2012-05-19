require 'rails/engine'
require 'oauth/rack/oauth_filter'
module Outsourced
  class Engine < Rails::Engine
    middleware.use OAuth::Rack::OAuthFilter
    config.autoload_paths << File.expand_path("../../../app/commands", __FILE__)
  end
end