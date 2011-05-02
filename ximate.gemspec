# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ximate/version'

Gem::Specification.new do |s|
  s.name        = 'ximate'
  s.version     = Ximate::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Enrico Pilotto']
  s.email       = ['enrico@megiston.it']
  s.homepage    = 'https://github.com/pioz/ximate'
  s.summary     = %q{Approximate fuzzy search for Ruby on Rails}
  s.description = %q{Approximate fuzzy search for Ruby on Rails activerecord models.}
  s.license     = 'MIT'

  s.rubyforge_project = 'ximate'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib', 'ext']
end
