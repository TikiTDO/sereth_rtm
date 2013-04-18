class sereth.tunnel.spec
  @data: []
  @register: (object, spec, args...) ->
    @data[[object, spec]] = new sereth.tunnel.spec(object, spec, args...)

  constructor: (@object, @spec, @schema, @initial = null) ->
