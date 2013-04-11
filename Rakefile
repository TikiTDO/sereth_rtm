require 'rubygems'

# Build, install and publish
require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

# Spec
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec
