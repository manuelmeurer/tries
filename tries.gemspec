# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'tries/version'

Gem::Specification.new do |gem|
  gem.name          = 'tries'
  gem.version       = Tries::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ['Manuel Meurer']
  gem.email         = 'manuel.meurer@gmail.com'
  gem.summary       = 'Solidify your code and retry on petty exceptions'
  gem.description   = 'Solidify your code and retry on petty exceptions'
  gem.homepage      = 'https://github.com/krautcomputing/tries'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r(^bin/)).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r(^(test|spec|features)/))
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec', '~> 2.12.0'
  gem.add_development_dependency 'rake', '~> 10.0.1'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.2'
  gem.add_development_dependency 'guard', '~> 1.5.2'
  gem.add_development_dependency 'guard-rspec', '~> 2.1.2'
end
