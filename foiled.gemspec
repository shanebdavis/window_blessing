# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foiled/version'

Gem::Specification.new do |gem|
  gem.name          = "foiled"
  gem.version       = Foiled::VERSION
  gem.authors       = ["Shane Brinkman-Davis"]
  gem.email         = ["shanebdavis@gmail.com"]
  gem.description   = %q{Curses! Foiled again!}
  gem.summary       = %q{A windowing framework for console apps.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'babel_bridge'
  gem.add_dependency 'gui_geometry', ">= 0.2.2"
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'guard-test'
  gem.add_development_dependency 'rb-fsevent'
  gem.add_development_dependency 'simplecov'
end
