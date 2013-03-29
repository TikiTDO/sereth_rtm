require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

project_name = "sereth_json_spec" 

desc 'Enable development commands'
task :devel do |task|
  sh '' # TODO: Write sed command  
end

desc 'Disable development commands'
task :prod do |task|
  sh '' # TODO: Write sed command  
end

desc 'Build the gem'
task :gem do |task|
  sh "gem build #{__dir__}/#{project_name}.gemspec"
end
