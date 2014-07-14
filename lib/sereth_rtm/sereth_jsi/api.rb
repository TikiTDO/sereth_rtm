class Sereth::JSI
  # A module should be able to inject JS handlers into the JSI
  def inject_jsi(bind_to_place, role, api_type)
  end

  # Should be able to generate JS based on included modules
  def export_js
  end

  # Should be able to list the JS capabilities based on included modules
  def export_capabilities
  end

  class << self
    # Generate a JSI instance for the given config
    def parse(config)
    end
  end

  # API
  #   Local
  #   Remote
  # 
  def register_access(name, prog)
  end

  # Serves individual assets, or asset groups.
  #  Must run the access handler for any served assets
  def serve(name: nil, group: nil)
  end

  # Store a named data element, optionally grouping in to a role. 
  #  May be marked as being present in all serve requests
  def store(name, group: nil, global: false)
  end
end