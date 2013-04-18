class sereth.tunnel.list
  constructor: (@path) ->
    @instances = {}
    @info = {page_size = null, inst_count = null}
    @pages = {}

  find: (id) ->
    new sereth.tunne.inst @instances[id]

  inst_count: () ->
    @info.inst_count

  page_count: () ->
    return @info.inst_count / @info.page_size if @info.page_count?
    return 0

  page: (number, callback = null) ->
