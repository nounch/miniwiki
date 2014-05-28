# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'miniwiki/version'

Gem::Specification.new do |spec|
  spec.name          = "miniwiki"
  spec.version       = Miniwiki::VERSION
  spec.authors       = ["nounch"]
  spec.email         = [""]
  spec.summary       = "Minimal Markdown Wiki"
  spec.description   = "Serves a directory full of markdown files as a \
browsable wiki."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
