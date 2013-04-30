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

def asset_recompile(env, target, dir)
  puts "Building: #{target} in #{dir}"
  env[target].write_to(File.join(dir, target))
rescue => e
  puts "!! Error compiling #{dir}/#{target}"
  puts "#{e.message}"
end

# Parse the static assets to produce the JS application, and any required tests
Jasmine.configure do |config|
  # Watch the inst script directory
  Thread.new do
    FileWatcher.new(*inst_sprockets.paths.to_a).watch do |filename|
      asset_recompile(inst_sprockets, 'tunnel.js', config.src_dir)
    end
  end
  # Watch the spec script directory
  Thread.new do
    FileWatcher.new(*spec_sprockets.paths.to_a).watch do |filename|
      asset_recompile(spec_sprockets, 'spec.js', config.spec_dir)
    end
  end
   
  # Pre-populate initial scripts
  asset_recompile(inst_sprockets, 'tunnel.js', config.src_dir)
  asset_recompile(spec_sprockets, 'spec.js', config.spec_dir)
end