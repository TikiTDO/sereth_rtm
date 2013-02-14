module Sereth
  class CallbackDB
    @serve = {}
    @types = {}

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
      target.send :alias_method, :pre_callback_method_added, :method_added
      target_class.send :remove_method, :method_added

      target_class.send :instace_variable_set, :@_callback_count, 0
    end

    # Generate a new method to handle this part of the callback
    def method_added(name)
      return pre_callback_method_added if CallbackDB.serves?(self, name)
      CallbackDB.each(self, name).each do |type, callback, count|
        callback_count = (@_callback_count += 1)
        target_name = "___callback_for_#{name}_#{callback_count}".to_sym
        target.send :alias_method, :target_name, name
        case type
        when :before
          target.send :define_method, name do |*args, &block|
            callback.call(*args, &block)
            self.send(target_name, *args, &block)
          end
        when :after
          target.send :define_method, name do |*args, &block|
            self.send(target_name, *args, &block)
            callback.call(*args, &block)
          end
        when :around
          target.send :define_method, name do |*args, &block|
            callback.call(*args) do
              self.send(target_name, *args, &block)
            end
          end
        else
          raise "Invalid callback type. Should never happen."
        end
      end

      
      return pre_callback_method_added
    end

    def before_method(name, conditional = false, &block)
      CallbackDB.save(:before, conditional, self, name.to_sym, block)
    end

    def after_method(name, conditional = false, &block)
      CallbackDB.save(:after, conditional, self, name.to_sym, block)
    end

    def around_method(name, conditional = false, &block)
      CallbackDB.save(:around, conditional, self, name.to_sym, block)
    end
  end
end