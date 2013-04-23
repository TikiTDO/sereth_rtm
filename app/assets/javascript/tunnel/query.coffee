class sereth.tunnel.query
  @send: (path, data, populate) ->
    delegate = $.ajax(path, data)

    delegate.error(@error)
    delegate.success () ->
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