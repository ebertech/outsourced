# -*- encoding: utf-8 -*-
require File.expand_path('../lib/outsourced/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Eberbach"]
  gem.email         = ["andrew@ebertech.ca"]
  gem.description   = %q{A distributed worker manager}
  gem.summary       = %q{A distributed worker manager}
  gem.homepage      = "http://ebertech.ca/"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "outsourced"
  gem.require_paths = ["lib"]
  gem.version       = Outsourced::VERSION

  gem.add_runtime_dependency "clamp"
  gem.add_runtime_dependency "state_machine"
  gem.add_runtime_dependency "paperclip", "< 3.0.2"
  gem.add_runtime_dependency "activerecord", "~> 3.1"
  gem.add_runtime_dependency "railties", "~> 3.1"
  gem.add_runtime_dependency "authlogic"
  gem.add_runtime_dependency "oauth"
  gem.add_runtime_dependency "oauth-plugin", "~> 0.4.0"
end
