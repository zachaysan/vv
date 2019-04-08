# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vv/version"

Gem::Specification.new do |spec|
  spec.name          = "vv"
  spec.version       = VV::VERSION
  spec.authors       = ["Zach Aysan"]
  spec.email         = %w( zachaysan@gmail.com )
  spec.summary       = %q{ Make ruby very v }
  spec.homepage      = "https://github.com/zachaysan/vv"
  spec.license       = "Nonstandard"
  spec.files         = `git ls-files -z lib spec`.split("\x0") + %w( README.markdown LICENSE.txt )
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_development_dependency "rake", "~> 12"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "minitest", "~> 5.11"

end
