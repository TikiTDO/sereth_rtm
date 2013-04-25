# Configure interface - Should accept a URL, data, and method. Will always return a 
# JSON object. 
#
# Should delegate to framework implementer. Default implementer is jQuery
#
# Data should be send to context promise waiter. Usually the data object
# Data object may itself subclass into list and inst


a = new query
wait = a.send(path, data, populate)
wait.done () ->
wait.error () ->

class sereth.tunnel.query
  @provider = {
    _: class # Template for providers
      init: () -> # 
      prepare: (url, data, method) ->
    jQuery: class

  }

  @send: (path, data, populate) ->
    defer = $.ajax(path, data)

    defer.error(@error)
    defer.success () ->
    # Block until done

  @error: (response = nil) ->
    # Generate an error

  @parse: (response) ->
    message = $.parseJSON(response)
    data = new sereth.tunnel.data

    # Populate data with the response information
    if !message.valid
      data.valid = false
    else
      data.valid = true
      data.path(message.namespace, message.object, message.spec)
      data.time = new Date();
      data.raw = message.raw

    # Return the data to handler
    return data