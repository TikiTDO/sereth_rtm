require 'bundler/setup'
Bundler.require(:default, :development)

module Sereth
  class Context
    class << self
      attr_reader :data
    end
  end
end

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
require_relative 'template_manager/tunnel_template'
if defined? Rails
  require_relative 'template_manager/drivers/rails'
elsif defined? Sprockets
  require_relative 'template_manager/drivers/sprockets' 
end




spr = Sprockets::Environment.new
spr.append_path Bundler.root + 'app/templates/compiled'
binding.pry
# TODO - Run any necessary stages
# Binding.run_stage(:sereth_util_loaded)
