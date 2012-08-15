# -*- encoding: utf-8 -*-
require File.expand_path('../lib/meekster/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Chris Mear"]
  gem.email         = 'chris@feedmechocolate.com'
  gem.description   = "Meekster implements a Meek Single Transferable Vote (STV) voting system, as described in the Proportional Representation Foundation's Reference Meek Rule."
  gem.summary       = "An implementation of the Meek STV election voting system."
  gem.homepage      = 'https://github.com/chrismear/meekster'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'meekster'
  gem.require_paths = ["lib"]
  gem.version       = Meekster::VERSION

  gem.add_development_dependency 'rspec', '~>2.9.0'
  gem.add_development_dependency 'rake', '~>0.9.2'
end
