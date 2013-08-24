=begin
# Wrapper System 
Implements around wrapper for any requested function.

## Usage:
class Example
  include Sereth::Wrapper

  around_method :method_name do |*args, &block| 
    print 'ar1'
    super(*args, &block)
    print 'ar2'
  end

  def method_name(*args, &block)
    print 'method'
  end
end

Example.new.method_name => ar1 method  ar2  
=end
module Sereth::Util
  # Permantly enables around callbacks for a given object. Ruby 1.9 only.
  module Wrapper
    def around_method(func_name, &callback)
      handler = Module.new
      handler.send :define_method, func_name, &callback
      self.send(:prepend, handler)
    end
  end
end
