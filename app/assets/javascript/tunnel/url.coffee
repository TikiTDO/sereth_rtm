class sereth.tunnel.url
  # Populates basic request info
  constructor: (@object, @spec, @namespace = null) ->
    @protocol = window.location.protocol
    @host = window.location.host

  set_host: (@host) ->
  set_protocol: (protocol) ->
    @protocol = protocol if protocol.match(/:$/)

  # Generate the path corresponding to this object
  generate: (id = null, type = null) ->
    ret = "#{@protocol}//#{@host}"
    ret += "/#{@namespace}" if @namespace
    ret += "/#{@object}"
    ret += "/#{id}" if id
    ret += "/#{type}" if type
    ret += ".json_spec?spec_name=#{@spec}"
    return ret
