## Content
1. [JavasScript Overview](#javascript-overview)
2. [JavasScript Library](#javascrilt-library)
  - [Core Types]()
      * [Context]()
      * [Perspective]()
      * [Object Sync]()
      * [Object Render]()
      * [URL Spec]()
      * [Error]()
  - [Templates]()
      * [Template Authoring]()
      * [Template Usage]()
      * [Template Processing]()

##
## JavaScript Overview
##

Registering a server-side data tunnel schema as a JavaScript context object, and
connecting it to data on the server:

```coffee
  # Generate a inst spec
  sereth.tunnel.register_spec("Data", "spec_name", schema, initial_data)

  # Enable server push (Optional)
  sereth.tunnel.enable_push("Data", "spec_name")

  # Query a single instance of the script default object by id, and return it as specced
  inst_tunnel = sereth.tunnel.get_inst("spec_name", id, params = {})
  # Specify a class for the instance instead of using script's default
  inst_tunnel = sereth.tunnel.get_inst("Data", "spec_name", id, params = {})
  
  # Note: Page sizing determined by server.
  # Query a list of instances, and return a given spec name. Defaults to page 1.
  list_tunnel = sereth.tunnel.get_list("spec_name", params = {}, page = null)
  # Specify a class for the list instead of using script's default. Defaults to page 1.
  list_tunnel = sereth.tunnel.get_list("Data", "spec_name", params = {}, page = null)
```
Communicating with the server

```coffee
  tunnel.poll() # Query data from the server
  tunnel.push() # Send data to the server

  tunnel.serverSignal((cur_data) ->) # Fired when server sends a signal
  tunnel.dataSent((new_data) ->) # Fired when data from server is changed
  tunnel.dataReceived((new_data) ->) # Fired when data from server is changed
  tunnel.dataError((cur_data) ->) # Fired when losing syncronization
```
Querying object data

```coffee
  # Inst
  # TODO: Should probably clone : http://stackoverflow.com/questions/728360/most-elegant-way-to-clone-a-javascript-object
  inst_tunnel.get('path/through/json') #= data_from_server['path']['through']['json']
  inst_tunnel.set('path/through/json', value) # Assuming 'json' is a settable value
  
  # Basic iteration will return immediate children of the path. These may be 
  inst_tunnel.each('path', (name, object)-> ...)
  # Deep iteration will return all low-level value objects from the path
  inst_tunnel.deep_each('path', (remaining_path, value)-> ...)

  # List
  # Find a instance of an object by id
  inst_tunnel = list_tunnel.find(id)

  # Information about the maximum number of items and pages in this list
  list_tunnel.inst_count() and list_tunne.page_count()
  # Returns array of inst_tunnels, or calls back with each inst in the page
  list_tunnel.page(number) or list_tunnel.page(number, (inst)-> )
```
**TODO** Binding a tunnel to a template 

```coffee
  # TODO
```
**TODO** Writing templates

```slim

```

##
## JavsScript Library
##

The javascript library provides a browser level interface into the tunnel.

## Context
The context joins the communication and operational layers into one congruent system

## Communication Layer
The communication layer sends and receives data from the server.

### Object Sync
Object sync represents a server data instance. Any changes to it can be pulled from the
server, or push to the server.

Follows server provided spec. Will only allow updates to settable methods.

In the future may even support server push.

### URL Spec
URL with reserved keys to fill in specific data. Used in conjunction with Sync Objects
these form the core communication mechanism.

### Error
General data object used to export failure information from server to client.


## Operational Layer
### Templates
JST based templates with contextual code.

### Object Render
Binds a server object type with a set of templates assigned to rendering different views
into an object

### Perspective
Handle multiple distinct views that are part of a single operational flow
