#= require_self
#= require_tree sereth

# requirejs - module autoload?

window.sereth = {}

# When operating in a browsers, utilize the param name global as with NodeJS
window.global = window if (typeof(window) != 'undefined') 

