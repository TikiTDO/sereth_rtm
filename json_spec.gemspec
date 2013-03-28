Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.0.0"

  s.name        = 'json_spec'
  s.version     = '1.0beta1'
  s.date        = '2013-03-27'
  s.summary     = "Sereth JSON Specification gem"
  s.description = "A gem to generate JSON specification from classes"
  s.authors     = ["Tikhon Botchkarev"]
  s.email       = 'TikiTDO@gmail.com'
  s.homepage    = 'https://github.com/TikiTDO/json_spec'
  s.license     = "MIT"

  s.add_dependency('rake')
  s.add_dependency('andand')
  s.add_dependency('binding_of_caller')
  s.add_dependency('sourcify')
  s.add_dependency('json')

  s.files       = `git ls-files -- lib/*`.split("\n")
end
