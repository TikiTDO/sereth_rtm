Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.0.0"

  s.name        = 'sereth_json_spec'
  s.version     = '1.0beta2'
  s.date        = '2013-02-03'
  s.summary     = "Sereth JSON Specification gem"
  s.description = "A gem to generate JSON schema and output from object instances"
  s.authors     = ["Tikhon Botchkarev"]
  s.email       = 'TikiTDO@gmail.com'
  s.homepage    = 'https://github.com/TikiTDO/sereth_json_spec'
  s.license     = "MIT"

  s.add_dependency('rake')
  s.add_dependency('andand')
  s.add_dependency('binding_of_caller')
  s.add_dependency('sourcify')
  s.add_dependency('json')

  s.files       = `git ls-files -- lib/*`.split("\n")
  s.test_files  = `git ls-files -- spec/*`.split("\n")
end
