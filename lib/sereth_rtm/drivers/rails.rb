# Add Sprockets Driver / Use default sprockets integration
# Configure new asset paths

# Inject template handler into the rails sprockets environment
#   Check that a template directory is available, warn to run task if not
#   Same with config?
#   Inject into main sprockets manifest
module Sereth
  class RTMRailtie < ::Rails::Railtie
    initializer 'sereth.initialize_rtm' do |rails_inst|
      
    end

    initializer 'sereth.after_rtm', after: 'sereth.initialize_rtm' do |rails_inst|
      # For plugins that want to live in RTM
    end

    # Load the rails rake tasks
    rake_tasks do
      tasks_path = Pathname.new(__dir__).join('tasks')
      tasks_path.each_entry do |entry|
        next if !entry.file?
        load entry
      end
    end

    # Load the rails generators
    generators do
      gen_path = Pathname.new(__dir__).join('tasks')
      gen_path.each_entry do |entry|
        next if !entry.file?
        require_relative entry
      end
    end
  end

  # Read configuration file
  config = YML.parse('rtm.yml')

  # Check if a permission callback is set in the config file
  if config['access']
    TemplateManager.set_access config['access']
  elsif some_default
    TemplateManager.set_access that_default
  end

  # Configure helper controller permissions
  routes = ::Rails.application.routes
  if !routes.has_route_for? TemplateServer
    $stderr.puts('[Template Manger] Warning: Template Server not routing')
    if config['auto_route']
      routes.add_resources 'sereth/templates', TemplateServer 
    end
  end
end