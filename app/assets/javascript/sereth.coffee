#= require_self
#
#= require core/context
#= require core/error

window.sereth = {}

# When operating in a browsers, utilize the param name global as with NodeJS
window.global = window if (typeof(window) != 'undefined') 