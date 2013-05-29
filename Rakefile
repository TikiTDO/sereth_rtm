require 'rubygems'

# Build, install and publish
require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

# Spec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end

begin
  require 'bower-rails'
  load 'tasks/bower.rake'
rescue LoadError
end
