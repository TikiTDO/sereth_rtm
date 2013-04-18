class sereth.tunnel.inst
  constructor: (@data) ->

  _clone_json: (data) ->

  _is_settable: () ->

  get: (path) ->

  set: (path, value) ->
    if @_is_settable(path)
