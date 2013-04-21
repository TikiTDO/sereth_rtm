class sereth.tunnel.inst
  constructor: (@data) ->
    @path = new sereth.tunnel.path(object, spec, namespace)


  # Clone the json object to prevent 
  _clone_json: (data) ->

  _is_settable: () ->

  get: (path) ->
    
    
  set: (path, value) ->
    if @_is_settable(path)
