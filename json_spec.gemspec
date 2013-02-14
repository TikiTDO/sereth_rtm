Gem::Specification.new do |s|
  s.require_ruby_version = ">= 1.9.2"

  s.name        = 'json_spec'
  s.version     = '0.1.0'
  s.date        = '2013-02-01'
  s.summary     = "Sereth JSON Specification gem"
  s.description = "A gem to generate JSON specification from classes"
  s.authors     = ["Tikhon Botchkarev"]
  s.email       = 'TikiTDO@gmail.com'
  s.homepage    = 'https://github.com/TikiTDO/json_spec'

  s.files       = `git ls-files -- lib/*`.split("\n")
end
