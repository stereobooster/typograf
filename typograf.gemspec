# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'typograf/version'

Gem::Specification.new do |gem|
  gem.name          = "typograf"
  gem.version       = Typograf::VERSION
  gem.authors       = ["stereobooster"]
  gem.email         = ["stereobooster@gmail.com"]
  gem.description   = %q{Universal tool for preparing russian text for web publishing. Ruby wrapper for typograf.ru webservice}
  gem.summary       = %q{Universal tool for preparing russian text for web publishing}
  gem.homepage      = "https://github.com/stereobooster/typograf"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "htmlentities"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
end
