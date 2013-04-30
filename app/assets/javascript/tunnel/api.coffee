class sereth.tunnel
  ## Private
  # Default data type for this tunnel. Will be set to the first one registered
  default_type = null

  # Private Access Helper
  _get_spec = (path...) ->
    if path.length == 2
      return sereth.tunnel.spec.get(path...)
    else if path.length == 1
      return sereth.tunnel.spec.get(default_type, path...)
    else
      throw "Invalid arguments" 

  # Add a spec to the tunnel spec to the interface. 
  register_spec: (data_type, spec_name, spec_schema, initial_data = null) ->
    sereth.tunnel.data_type = data_type if sereth.tunnel.default_type?
    new sereth.tunnel.spec(data_type, spec_name, spec_schema, initial_data = null)

  ## Public
  # Create a new instance of the spec for upload
  make_inst: (path...) ->
    spec = _get_spec(path...)
    result = "Create a new inst"
    context.bind('inst', spec).to(result)

  # Get an existing instance of the spec from server
  get_inst: (path..., id, params = {}) ->
    spec = _get_spec(path...)
    result = "Get either default values, or pull from server."
    context.bind('inst', spec).to(result)

  # Get multiple instance of the spec from server
  get_list: (path..., params = {}) ->
    spec = _get_spec(path...)
    result = "Get either default values, or pull from server."
    context.bind('list', spec).to(result)

class sereth.tunnel.inst
  constructor: (@data) ->
    @path = new sereth.tunnel.path(object, spec, namespace)

  get: (path) ->
    
    
  set: (path, value) ->
    

class sereth.tunnel.list
  constructor: (@path) ->
    @instances = {}
    @info = {page_size: null, inst_count: null}
    @pages = {}

  find: (id) ->
    new sereth.tunne.inst @instances[id]

  inst_count: () ->
    @info.inst_count

  page_count: () ->
    return @info.inst_count / @info.page_size if @info.page_count?
    return 0

  page: (number, callback = null) ->
    if !@pages[number]?
      @_load