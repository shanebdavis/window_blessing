# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'window_blessing/version'

Gem::Specification.new do |gem|
  gem.name          = "window_blessing"
  gem.version       = WindowBlessing::VERSION
  gem.authors       = ["Shane Brinkman-Davis"]
  gem.email         = ["shanebdavis@gmail.com"]
  gem.description   = "Forget Curses! Try Blessings! WindowBlessing is an evented, windowing framework for terminal apps."
  gem.summary       = ""
  gem.homepage      = "https://github.com/shanebdavis/window_blessing"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'babel_bridge', ">= 0.5.3"
  gem.add_dependency 'gui_geometry', ">= 0.2.2"
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'guard-test'
  gem.add_development_dependency 'rb-fsevent'
  gem.add_development_dependency 'simplecov'
end
