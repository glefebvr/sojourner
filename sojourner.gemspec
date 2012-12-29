# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sojourner/version'

Gem::Specification.new do |gem|
  gem.name          = "sojourner"
  gem.version       = Sojourner::VERSION
  gem.authors       = ["Olivier Saut"]
  gem.email         = ["osaut@airpost.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{Parameter space rover for mathematical models.}
  gem.homepage      = "http://kesaco.eu"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # Dépendances
  gem.add_runtime_dependency 'celluloid'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'yard'
end
