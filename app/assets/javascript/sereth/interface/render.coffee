# Context Container
class sereth.render
  # Access to the class instance from prototype and object instance
  @class: @
  class: @ 

  ## Class Data
  @data: {}

  # Register the render_context for a given template
  @register: (template_path, context_generator) ->
    # Instantiate an instance to store the template
    render = new @class(template_path)
    # Ensure the template is initialized with the correct data
    render_populate = new sereth.render_populate(render)
    context_generator(render_populate)
    # Store the template
    @data[template_path] = render
    
  ## Instance Data
  constructor: (template_path) ->
    @context = new sereth.context('render')
    @context.name = template_path

  loaded: () ->
    @context.iterator('load').each (callback) -> callback(@context)

  render: (locals) ->
    inst = @context.inst()
    # A yield chain will fail if one of the yield callbacks fails to call the yield function
    return if !inst.yield_chain 'gate'
    # Run the template 
    template = inst.get('template')
    return template(locals)

# The inst driver serves as the binding point for external frameworks
class sereth.render_inst
  # Tries to configure the render driver
  constructor: (@inst_context) ->
    @configure?()

  # Driver should call render when content is to be rendered
  render: (locals) ->
    # A yield chain will fail if one of the yield callbacks fails to call the yield function
    return if !@inst_context.yield_chain 'gate'
    # Run the template 
    return @inst_context.call_with('template', locals)

  # Driver should call remove when rendered content is no longer necessary
  remove: () ->
    @inst_context.call_chain('cleanup')
    @inst_context.remove()

# Class to handle the initial configuration of the render instance
class sereth.render_populate
  constructor: (@render) ->
    @context = @render.context

  #- Registration
  load: (callback_array) ->
    fail if typeof callback_array != "array"
    @context.collection('load', callback_array)

  gate: (callback_array) ->
    fail if typeof callback_array != "array"
    @context.collection('gate', callback_array)

  template: (callback) ->
    fail if typeof callback_array != "function"
    @context.callback('template', callback)

  config: (object) ->
    fail if typeof callback_array != "object"
    @context.data('config', object)