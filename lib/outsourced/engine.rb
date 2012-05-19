require 'rails/engine'
require File.expand_path('../rack_filter.rb', __FILE__)
module Outsourced
  class Engine < Rails::Engine
    middleware.use Outsourced::RackFilter

    config.autoload_paths.delete(File.expand_path("../../../app/controllers", __FILE__))
    config.autoload_paths.delete(File.expand_path("../../../app/models", __FILE__))

    config.autoload_once_paths << File.expand_path("../../../app/commands", __FILE__)
    config.autoload_once_paths << File.expand_path("../../../app/models", __FILE__)
    config.autoload_once_paths << File.expand_path("../../../app/controllers", __FILE__)
  end
end