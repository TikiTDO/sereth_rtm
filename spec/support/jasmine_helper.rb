#Use this file to set/override Jasmine configuration options
#You can remove it if you don't need it.
#This file is loaded *after* jasmine.yml is interpreted.
#
#Example: using a different boot file.
#Jasmine.configure do |config|
#   config.boot_dir = '/absolute/path/to/boot_dir'
#   config.boot_files = lambda { ['/absolute/path/to/boot_dir/file.js'] }
#end
#
require 'coffee-script'
require 'sprockets'
require 'pry'

# Configure Sprockets for gem
inst_sprockets = Sprockets::Environment.new
inst_sprockets.append_path 'app/assets/javascript'

spec_sprockets = Sprockets::Environment.new
spec_sprockets.append_path 'spec/javascript'

Jasmine.configure do |config|
  inst_sprockets['test.js'].write_to(File.join(config.src_dir, 'test.js'))

  spec_sprockets['spec.js'].write_to(File.join(config.spec_dir, 'spec.js'))
end