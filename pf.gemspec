# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pf/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Joaquin Lopez"]
  gem.email         = ["mrgus@disco-zombie.net"]
  gem.description   = %q{Password Finder}
  gem.summary       = %q{Simple Password Management System}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "pf"
  gem.require_paths = ["lib"]
  gem.version       = Pf::VERSION
end
