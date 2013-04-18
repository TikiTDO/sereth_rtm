class sereth.tunnel.query
  @send: (path, data, populate) ->
    delegate = $.ajax(path, data)

    delegate.error(@error)
    delegate.success () ->
    # Block until done

  @error: (response = nil) ->
    # Generate an error

  @parse: (response) ->
    # Check if the response data is a valid tunnel response
    error(response) if !@valid(response)
