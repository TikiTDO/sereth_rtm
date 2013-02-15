module Sereth
  class CallbackDB
    @serve = {}
    @types = {}
    @counts = {}

    class << self
      def next_cb(name)
        @counts[name] ||= 0
        @counts[name] += 1
        cur_cb
      end

      def cur_cb(name)
        "___callback_for_#{name}_#{@counts[name]}"
      end

      def serves?(type, name)
        key = type.hash ^ name.hash
        return @serve[key]
      end

      def save(op, conditional, type, name, block)
        @types[type] ||= {}
        type_db = @types[type]
        type_db[name] = block

        key = type.hash ^ name.hash
        @conds[key]
      end
    end
  end

  # Enables befre, after, and around callbacks for a given object. Ruby 1.9 only.
  module Callbacks
    # This module is only for extension
    def self.included(target)
      raise "The #{self} Module should only be extended."
    end

    # Add the callback method added to the method_added stack
    def self.extended(target)
      target_class = class << target; self; end
      # Stack the method_added callback
      target.send :alias_method, :_precb_method_added, :method_added
      # Force module to override this method
      target_class.send :remove_method, :method_added

      target_class.send :instace_variable_set, :@_callback_active, false
      target_class.send :instace_variable_set, :@_callback_count, 0
    end

    def _inject_before_callback

    end

    def _inject_after_callback

    end

    def _inject_around_callback

    end

    # Generate a new method to handle this part of the callback
    def method_added(name)
      # Ignore methods being defined for the callback process
      return _precb_method_added if @callback_active
      # Notify self that we are adding callbakcs
      @_callback_active = true
    
    
      current_top = CallbackDB.cur_cb(name)
      if self.method_defined?(current_top)
        # All callbacks aready defined. Just refresh the top and botton levels

      else
        # Need to define all the callbacks
        CallbackDB.each(self, name) do |type, callback, count|
        callee_name = CallbackDB.next_cb(name)
        self.send :alias_method, callee_name, name
        case type
        when :before
          self.send :define_method, name do |*args, &block|
            callback.call(*args, &block)
            self.send(callee_name, *args, &block)
          end
        when :after
          self.send :define_method, name do |*args, &block|
            self.send(callee_name, *args, &block)
            callback.call(*args, &block)
          end
        when :around
          self.send :define_method, name do |*args, &block|
            callback.call(*args) do
              self.send(callee_name, *args, &block)
            end
          end
        else
          raise "Invalid callback type. Should never happen."
        end
        end
      end
      
      # Finished adding callbacks
      @_callback_active = false
      return _precb_method_added
    end

    alias_shift_args :before_method, :_add_callback, :before
    alias_shift_args :after_method, :_add_callback, :after
    alias_shift_args :around_method, :_add_callback, :around
    def _add_callback(type, conditional, &block)

    end
  end
end