$:.unshift File.expand_path("../lib", __FILE__)
require 'sereth_rtm/version'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.0.0"

  s.name        = 'sereth_rtm'
  s.version     = "#{Sereth::RTM::VERSION}"
  s.date        = Time.now
  s.summary     = "Ruby <=> HTML5 development interface"
  s.description = "A gem to manage communication between Ruby based server and" +
    "HTML5 based clients."
  s.authors     = ["Tikhon Botchkarev"]
  s.email       = 'TikiTDO@gmail.com'
  s.homepage    = 'https://github.com/TikiTDO/sereth_rtm'
  s.license     = "MIT"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.add_dependency('sereth_utils')

  # Ruby Component
  s.add_dependency('rake')
  s.add_dependency('andand')
  s.add_dependency('binding_of_caller')
  s.add_dependency('sourcify')
  s.add_dependency('json')
  s.add_dependency('hike')

  # JS Component
  #s.add_dependency('bower-rails')
  s.add_dependency('rkelly_for_reef')
  s.add_dependency('uglifier')
  s.add_dependency('coffee-script')


  # TODO: Fast Object to JSON encoder. Better performance than native JSON
  #gem 'yajl-ruby' 
  s.files       = `git ls-files -- {lib,app}/*`.split("\n")
  s.test_files  = `git ls-files -- spec/*`.split("\n")
end
