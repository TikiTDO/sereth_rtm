class sereth.tunnel
  # Default data type for this tunnel. Will be set to the first one registered
  @default_type = null

  register_spec: (data_type, spec_name, spec_schema, initial_data = nil) ->
    sereth.tunnel.data_type = data_type if sereth.tunnel.default_type?
    new sereth.tunnel.spec(data_type, spec_name, spec_schema, initial_data = nil)

  _get_spec: (path...) ->
    if path.length == 2
      return sereth.tunne.spec.get(path...)
    else if path.length == 1
      return sereth.tunne.spec.get(sereth.tunnel.default_type, path...)
    else
      throw "Invalid arguments" 

  get_inst: (path..., id, params = {}) ->
    spec = @_get_spec(path...)

    [data_type, spec_name, id, params] = args if args.lenght == 4


  get_list: (path..., params = {}, page = null) ->
    spec = @_get_spec(path...)