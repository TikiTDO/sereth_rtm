# Jasmine configuration in spec/javascripts/support/jasmine.yml
require 'coffee-script'
require 'sprockets'
require 'filewatcher'
require 'pry'


# Configure Sprockets for gem
inst_sprockets = Sprockets::Environment.new
inst_sprockets.append_path 'app/assets/javascript'

spec_sprockets = Sprockets::Environment.new
spec_sprockets.append_path 'spec/javascripts'

# Parse the static assets to produce the JS application, and any required tests
Jasmine.configure do |config|
  # Watch the inst script directory
  Thread.new do
    FileWatcher.new(*inst_sprockets.paths.to_a).watch do |filename|
      inst_sprockets['test.js'].write_to(File.join(config.src_dir, 'test.js'))
    end
  end
  # Watch the spec script directory
  Thread.new do
    FileWatcher.new(*inst_sprockets.paths.to_a).watch do |filename|
      spec_sprockets['spec.js'].write_to(File.join(config.spec_dir, 'spec.js'))
    end
  end
   
  # Pre-populate initial scripts
  inst_sprockets['test.js'].write_to(File.join(config.src_dir, 'test.js'))
  spec_sprockets['spec.js'].write_to(File.join(config.spec_dir, 'spec.js'))
end