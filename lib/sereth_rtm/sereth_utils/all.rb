# Ensure the sereth namespace exists
module Sereth::Util
  # The sereth handler offers up the current context
  def sereth
    return Context.current
  end

  include AliasArgs
  include Wrapper
end

# Register the sereth handler
class Object
  include Sereth
end


raise LoadError, 'Ruquires Ruby 2' if !RUBY_VERSION.match(/^2/)
require 'rubygems'
require 'pry'
require 'andand'
require 'binding_of_caller'

# Use staging for all following code.
require_relative './stage'
require_relative './alias_args'
require_relative './callbacks'

Binding.run_stage(:sereth_util_loaded)