
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'traxor/version'

Gem::Specification.new do |spec|
  spec.name          = 'traxor'
  spec.version       = Traxor::VERSION
  spec.authors       = ['Ryan Hansen']
  spec.email         = ['ketiko@gmail.com']

  spec.summary       = 'Log metrics to akkeris platform'
  spec.description   = 'Log metrics to akkeris platform'
  spec.homepage      = 'https://github.com/ketiko/traxor'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'

  spec.add_dependency 'activesupport', '>= 5.0'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'faraday'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sidekiq'
  spec.add_development_dependency 'simplecov'
end
