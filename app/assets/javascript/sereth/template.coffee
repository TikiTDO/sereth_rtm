class sereth.template
  # A template holds the parsed scripts, and the generating JS code
  # 
  # A template is initialized with some code which runs whenenever this template is 
  # redered.  Code added to context. Should learn to extract it from source.
  #
  # Detect if a context has not been bound in the template. Separate commands for
  # rendering raw templates