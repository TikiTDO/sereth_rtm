
class sereth.context


  defineType: () ->



## THIS IS A TREE
## WOW
##  -90dfzgkloh gd
# Root Title
# Parent -> Node -> Children
# Node -> link to Nodes under different titles
# Data Query - Child to parent

# Will inject __defineGetters__ into the global 

# .get method for 

# Inject directly into controller, and get path from there. Query routes if anything
# References



$ () ->
  global.context = new sereth.context

  # Enable context based logging
  console.debug = (args...) ->
    space = ""
    for num in [1..sereth.context.__depth]
      space += "  " if num > 1
    console.log(space, args...)


class sereth.context
  @__univeral_entry_callbacks: []
  @__univeral_exit_callbacks: []
  @__depth: 0

  register_type: (ctx_type) ->
    global.__defineGetter__ ctx_type, () ->
      # Query the context for this type

  # Instantiate a new worker, and populate it with a properly related context
  spawn_worker: () ->

  constructor: (name = null, parent = null) ->
    @fresh = true
    @name = name
    @__sub_contexts = {}
    @__entry_callbacks = []
    @__exit_callbacks = []
    @parent = parent
    @depth = sereth.context.__depth + 1
    sereth.context.__depth = @depth if sereth.context.__depth == 0
    console.debug("Init Ctx #{`(name ? name : 'root')`}")

  ## Operation Initialization
  # Register callback(s) that fire each time a new context is entered from the current one,
  #   and execute that callback if it is being added to a newly created context
  register_entry: (entry_callbacks...) ->
    console.debug("Reg Ent")
    for entry_callback in entry_callbacks
      @__entry_callbacks.push(entry_callback) 
      entry_callback() if @fresh

  # Register callback(s) that fire each time a context is entered, and immediately execute it
  #   for the current context
  universal_entry: (entry_callbacks...) ->
    console.debug("Reg Univ Ent")
    for entry_callback in entry_callbacks
      sereth.context.__univeral_entry_callbacks.push(entry_callback)     
      entry_callback()

  # Register callback(s) that fire each time a the current context is exited
  register_exit: (exit_callbacks...) ->
    console.debug("Reg Ex")
    @__exit_callbacks.push(exit_callback) for exit_callback in exit_callbacks

  # Register callback(s) that fire each time a context is exited
  universal_exit: (exit_callbacks...) ->
    console.debug("Reg Ex")
    for exit_callback in exit_callbacks
      sereth.context.__univeral_exit_callbacks.push(exit_callback) 

  ## Context Navigation (Affects Freshness)
  # Finds or creates a context of a given name in the current context, and makes it current.
  enter_context: (name) ->
    console.debug("Entering ctx: #{name}")
    @__sub_contexts[name] = new sereth.context(name, this) if !@__sub_contexts[name]?
    @_update_context(@__sub_contexts[name])

  # Makes the parrent the current context
  leave_context: () ->
    console.debug("Leaving ctx: #{@name}")
    @_update_context(@parent)
  
  # Makes the parrent the current context, and removes this and all sub_contexts
  forget_context: () ->
    console.debug("Forget ctx: #{@name}")
    @leave_context()    
    @parent._forget_sub_contexts(@name)

  ## Interanl Operation
  # Run the universal entry, then 
  _execute_entry: () ->
    callback() for callback in sereth.context.__univeral_entry_callbacks
    callback() for callback in @__entry_callbacks

  _execute_exit: () ->
    callback() for callback in sereth.context.__univeral_exit_callbacks
    callback() for callback in @__exit_callbacks

  _update_context: (new_context) ->
    @fresh = false
    @_execute_exit()
    current_context = new_context
    sereth.context.__depth = new_context.depth
    new_context._execute_entry()
    new_context

  # Forgets either all the named context, or all child contexts if none named
  _forget_sub_contexts: (names...) ->
    if names.length > 0
      for name in names
        @__sub_contexts[name]._forget_sub_contexts()
        delete @__sub_contexts[name] 
    else
      delete @__sub_contexts[name] for name, sub_context of @__sub_contexts

