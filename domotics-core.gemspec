# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'domotics/core/version'

Gem::Specification.new do |spec|
  spec.name          = "domotics-core"
  spec.version       = Domotics::Core::VERSION
  spec.authors       = ["goredar"]
  spec.email         = ["info@goredar.it"]
  spec.summary       = %q{Home automation system.}
  spec.description   = %q{Main core elements}
  spec.homepage      = "https://goredar.it"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "domotics-arduino"
  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "hiredis"
  spec.add_runtime_dependency "mongo"
  spec.add_runtime_dependency "bson_ext"
  spec.add_runtime_dependency "rack"
  spec.add_runtime_dependency "rb-inotify"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "rack-test"
end
