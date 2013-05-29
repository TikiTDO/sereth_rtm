$:.unshift File.expand_path("../lib", __FILE__)
require 'json_tunnel/version'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.0.0"

  s.name        = 'json_tunnel'
  s.version     = "#{Sereth::JsonTunnel::VERSION}"
  s.date        = Time.now
  s.summary     = "Sereth JSON Specification gem"
  s.description = "A gem to generate JSON schema and output from object instances"
  s.authors     = ["Tikhon Botchkarev"]
  s.email       = 'TikiTDO@gmail.com'
  s.homepage    = 'https://github.com/TikiTDO/sereth_json_spec'
  s.license     = "MIT"

  s.add_development_dependency "bundler", ">= 1.0.0"

  # Ruby Component
  s.add_dependency('rake')
  s.add_dependency('andand')
  s.add_dependency('binding_of_caller')
  s.add_dependency('sourcify')
  s.add_dependency('json')

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
