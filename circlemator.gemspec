# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'circlemator/version'

Gem::Specification.new do |spec|
  spec.name          = 'circlemator'
  spec.version       = Circlemator::VERSION
  spec.authors       = ['Emanuel Evans']
  spec.email         = ['emanuel@rainforestqa.com']

  spec.summary       = 'A bucket of tricks for CircleCI and Github.'
  spec.description   = <<-EOF.strip
    A few utilities for CircleCI to improve your CI workflow.
  EOF
  spec.homepage      = 'https://github.com/rainforestapp/circlemator'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty', '~> 0.13.7'
  spec.add_dependency 'pronto', '~> 0.9.5'
  spec.add_dependency 'pronto-rubocop', '~> 0.9.0'
  spec.add_dependency 'pronto-commentator', '~> 0'
  spec.add_dependency 'pronto-undercover', '~> 0.1'
  spec.add_dependency 'pronto-brakeman', '~> 0.9.1'

  spec.add_development_dependency 'bundler', '>= 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'vcr', '~> 4.0.0'
  spec.add_development_dependency 'webmock', '~> 3.7.5'
  spec.add_development_dependency 'rspec', '~> 3.4.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-html'
  spec.add_development_dependency 'simplecov-lcov'
end
