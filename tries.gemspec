# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'tries/version'

Gem::Specification.new do |gem|
  gem.name          = 'tries'
  gem.version       = Tries::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.author        = 'Manuel Meurer'
  gem.email         = 'manuel@krautcomputing.com'
  gem.summary       = 'Solidify your code and retry on petty exceptions'
  gem.description   = 'Solidify your code and retry on petty exceptions'
  gem.homepage      = 'https://github.com/krautcomputing/tries'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r(^bin/)).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r(^(test|spec|features)/))
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 2.13.0'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.2'
  gem.add_development_dependency 'guard-rspec', '~> 2.5'
  # Listen >= 2.0.0 only works with Ruby >= 1.9.3
  gem.add_development_dependency 'listen', '< 2.0.0' if RUBY_VERSION < '1.9.3'
  gem.add_runtime_dependency 'gem_config', '~> 0.2'
end
