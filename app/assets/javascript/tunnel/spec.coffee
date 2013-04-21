class sereth.tunnel.spec
  @data: []

  @get: (data_type, spec_name) ->
    @data[[data_type, spec_name]]

  constructor: (@data_type, @spec_name, @schema, @initial = null) ->
    sereth.tunnel.spec.data[[@data_type, @spec_name]] = this