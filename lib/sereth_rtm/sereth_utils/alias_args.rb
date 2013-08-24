=begin
# Usage:

class Thing
  def method_name(*args)
    args
  end
  alias_shift_arg(:method_changed, :method_name, 1, 2, 3)
end


thing = Thing.new
thing.method_name("a").inspect #=> ["a"]
thing.method_changed("a").inspect #=> [1, 2, 3, "a"]
=end

module Sereth::Util
  module AliasArgs
    # Register an alias before the method is defined. Not for performance critical use
    def alias_preload(target, source) 
      self.send(:define_method, target) do |*orig_args, &block|
        self.send(source, *orig_args, &block)
      end
    end

    # Register a method that appends some arguments before calling the aliased method
    def alias_push_args(target, source, *args)
      self.send(:define_method, target) do |*orig_args, &block|
        self.send(source, *(orig_args + args), &block)
      end
    end

    # Register a method that prepends some arguments before calling the aliased method
    def alias_shift_args(target, source, *args)
      self.send(:define_method, target) do |*orig_args, &block|
        self.send(source, *(args + orig_args), &block)
      end
    end  
  end
end
