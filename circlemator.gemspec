# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'circlemator/version'

Gem::Specification.new do |spec|
  spec.name          = "circlemator"
  spec.version       = Circlemator::VERSION
  spec.authors       = ["Emanuel Evans"]
  spec.email         = ["emanuel@rainforestqa.com"]

  spec.summary       = %q{A bucket of tricks for CircleCI and Github.}
  spec.description   = %q{A bucket of tricks for CircleCI and Github.}
  spec.homepage      = "https://github.com/rainforestapp/circlemator"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.13.7"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
