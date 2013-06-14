require 'bundler/setup'
Bundler.require(:default, :development)

# Sereth Libraries
require_relative 'sereth_utils/all'

# JSON Spec
require_relative 'json_tunnel/utils'
require_relative 'json_tunnel/generator'
require_relative 'json_tunnel/cache'
require_relative 'json_tunnel/exports'
require_relative 'json_tunnel/imports'
require_relative 'json_tunnel/data'
require_relative 'json_tunnel/api'

# Template Manager
require_relative 'template_manager/api'
require_relative 'template_manager/data_model'
require_relative 'template_manager/manifest'
require_relative 'template_manager/parser'

# Load rails drivers, or failing that just the sproject integration
require_relative 'template_manager/drivers/tilt'
if defined? Rails
  require_relative 'template_manager/drivers/rails'
elsif defined? Sprockets
  require_relative 'template_manager/drivers/sprockets' 
end

require_relative 'template_manager/drivers/rake' if defined? Rake


# Debugging Stuff
spr = Sprockets::Environment.new
spr.append_path Bundler.root + 'app/templates/compiled'
binding.pry
# TODO - Run any necessary stages
# Binding.run_stage(:sereth_util_loaded)
