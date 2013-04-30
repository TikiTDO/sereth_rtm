Tunnel
  Define Spec (What JSON looks like, object name, spec name, server url)
  Instantiate first request
  Get data from server

  Save data to server

Render
  Bind data to sets of templates for rendering instance/list/form perspectives

  Allow server pushes from changes made to defined forms


Usage:
  Take a bunch of data
  Originated from tunnel
  bind data to perspectives (auto?)

  render data into containers

  render data into perspectives
    perspective starts a new window level container (context)
    perspective management happens with entry/exit callbacks

    perspective context pre-configured by parent

  rendered forms are bound to data objects. Form updates are saved to objects, which are then
  pushed to the server as necessary.
    call back before populate, then before and after commit
    before populate for custom data validation and such


  Templates - 
    Templates contain slim style code, and context javascript. 
    Any script tags in the resulting object are extracted and parsed in the context of
    the given location. Context has access to a container element which contains the
    generated html. 

    Template should allow for inline definition of sub-templates for quick 

  Context - 
    Contexts provide a shared space for accessing functions and variables. 

    Contexts are managed by callbacks which populate the actual contex entries

    From your contextual position you can see multiple contexts. If you've created a context
    but did not define a link type for it, the future link searches will query super-cts links

    Context need follow linkage

    Admin Environment
      Initiate root Worker Context W1
      Renders admin header
        Render provided HTML
        Does system wide init operations
      Load Tree Node page
        Create a worker context (W1 ->) W2
        Create a data context D1
          Bind tree node spec to created data context
          Link data to worker contexts
        Create a render context R1
          Bind render inst to create render context
          Link render to worker context
      Edit a Tree Node
        Create a content context (C2 ->) C3
        Create a render context (R1 ->) R2
        Query content for data link - returns C3 -> C2 -> D1
        Update some data to create (D1 ->) D1*
        Save D1*
        Leave content context C3
          Should return to (C2 D1 R1)
          Should notify D1 to reload due to D1*

Query contexts 

  Default access to worker context
    window.context

  Access to object's context
    this.context

  context.name -- Get the [name] type bound to the worker
    context or {}.context 

  generate_context(object, type) OR (object, ctx_parent)
  local_context.name --




Object.__proto__.test = function () {console.log('1')};
a = function () {
  this.test = function () {console.log('2')};
}

a.prototype.woo = function () {test()};

aa = new a();
aa.woo();