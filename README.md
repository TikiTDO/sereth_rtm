# Sereth Ruby Template Manager

UNDER DEVELOPMENT - DO NOT USE

**Requires Ruby 2.0**

Sereth RTM is a Ruby and CoffeeScript library developed to establish a common data representation and communication 
layer between a Ruby based server, and a JavaScript based web client.

The core goals of this project are to facilitate the export of fine-grained ruby objects into highly-dynamic
JavaScript templates, allow web clients to use these templates in order to render a web page, and to facilitate a mechanism for remote clients to track and update server based data when
for these web clients to keep this data syncronized with the server when authorized to do so.

**For Web Developers:** Please consult the usage guides for:
* [Ruby &harr; JS Interface](docs/usage.tunnel.md)
* [JS Templatesl](docs/usage.template.md)
* [Rails Integration](docs/usage.rails.md)

**For Ruby Developers:** Please consult the design notes for:
* [Ruby &harr; JS Interface](docs/design.tunnel.md)
* [JS Templates](docs/design.template.md)
* [Rails Integration](docs/design.rails.md)

## Installation

For the purpose of this example we will be using a new rails project. Skip the
generation step if using with an existing rails proejct.

```bash
 $ rails new rtm_demo
```

Add the json_rtm gem to the Gemfile.

```
Gemfile << gem 'rtm-json'
$ bundle install
```

Run rake task to generate the template structure
```
$ rake rtm:new
```

... TODO Install Guide ...

## JSON Tunnel Overview
```ruby
class Data
  json_spec :spec_name do
    ## Nodes
    # Key-Value Nodes
    node_name #=> "node_name": #{inst.node_name}
    node_name :symbol #=> "node_name": #{inst.symbol)}
    node_name get: proc, set: proc {|value|} #=> "node_name": #{inst.instance_eval(&proc)}

    # Typed Key-Value Nodes (Exception on invalid types)
    node_name type: Type, ... # Same operation as normal Key-Value nodes

    # Key-Array Nodes
    node_name Array #=> "node_name": [#{inst.node_name.each {|val| val}}]
    node_name Array, :symbol #=> "node_name": [#{inst.node_name.each(&:symbol)}]
    node_name Array, get: proc set: proc {|parsed_array|} #=> "node_name": [#{inst.instance_eval(&proc)}]

    # Typed Key-Array Nodes (Exception on invalid types)
    node_name Array, type: Type, ... # Same operation as normal Key-Array nodes

    # Key-Object Nodes 
    node_name do ... end 
      #=> "node_name": {#{json_spec.from(&block).apply(inst.node_name)}}

    # Key-Array of Object Nodes
    node_name Array do ... end 
      #=> "node_name": [#{inst.node_name.each {|item| json_spec.from(&block).apply(item)}}]

    ## Operations
    override! :node_name, ... # Identical functionality to above. Useful for ruby keyword names
    extends! :spec_name # Extend from a different spec in the same node
    extends! DataClass, :spec_name # Extend from a different spec for a different node
    extends! 'collection_name', :spec_name # Sambe as above, for rails collection names
    if! proc do ... end # Exted current spec if proc returns true in context of current inst
  end
end
```

## Template Manager Overview
Example written in Slim using CoffeeScript. Any template engine which compiles
to HTML with JavaScript may be used.

```slim
  / First tag must compile to javascript.
  coffee:
    # Manifest Configuration
    config {key: value}
    
    # Executed when the template is first loaded into the render engine
    load (render_context) ->
      # May be called multiple times to set up multiple handlers. Example uses:
      #   Inject new dependences and subtask into the context
      #   Pre-loading templates for permission based perspectives
      render_context.inst_handlers # See Below
      render_context.clean_handlers # See below
      render_context.set(key, value) # Parameters to export to the inst contexts
      render_context.get(key) # Currently set parameters

    # Executed when the template is instantiated, must yield to render
    inst (container, locals, context) ->
      container # The DOM element to contain the actual template
      locals # The variables to be passed into the render stage
      yield(); # Calls into the render stage 
      # ? no_yield(); # Tells the render stage not to yield at all
    
    # Executed when the template is removed from the document.
    clean (render_inst_context) ->
      
  / All subsequent HTML will be converted into an EJS template
  .example
    .slim
  / Inline Partials are extracted from the slim document, and served with the template
  partial
    coffee:
      ...
```

## Template &rarr; JSON Binding
TODO - Example written in Slim.

```slim
  = json_tunnel(@object, :spec)
```

## Links
[Useful Links](docs/cool-links.md) | [Usecases](docs/usecases.md)

## TODO
Use async script loading for core elements

```javascript
function () {
  var scr = document.createElemetn('script'); scr.type = 'text/javascript';
  scr.async = true; src.src = 'http://blah';
  var s = documetn.getElementsByTagName('script')[0];
  s.parentNode.insertBefore(src, s);
}
```

Remote spec type - Format

Include tattletale for console debugging

GitHub Integrator?

Stream results directly. Prolly not, seems slower unless rails4 improves it