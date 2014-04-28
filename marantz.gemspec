$:.push File.expand_path('../lib', __FILE__)
require 'marantz/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'marantz'
  s.version     = Marantz::VERSION
  s.author      = 'Christopher Svensson'
  s.email       = 'stoffus@stoffus.com'
  s.homepage    = 'https://github.com/stoffus/marantz-rb'
  s.summary     = 'Ruby client for controlling Marantz AVRs.'
  s.description = 'Ruby client that uses Marantz web interface as an API.'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 1.9.3'
  s.required_rubygems_version = '>= 1.8.11'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
