=begin
# Callback System 
Implements before, after, and around callbacks for any requested function.

## Usage:
class Example
  include Sereth::Callback

  before_method :method_name do |*args, block| 
    puts 'b'
  end
  before_method :method_name do |*args, block| 
    puts 'b1'
  end
  after_method :method_name do |*args, block| 
    puts 'af' 
  end
  after_method :method_name do |*args, block| 
    puts 'af1' 
  end
  around_method :method_name do |*args| 
    puts 'ar1' && yield && puts 'ar2'
  end
  around_method_full :method_name do |{:args => [], :block => block}|
    puts 'arf1' && yield && puts 'arf2
  end

  def method_name(*args, &block)
    puts 'method'
  end
end

Example.new.method_name => arf1 ar1 b1 b method af af1 ar2 arf2

## Ordering
Call-in order priority increases for later defines. 
Call-out priority decreases for same.

## Special Consideration
The system maintains the existing callbacks when a method is re-implemented.

## Callback Types
  Handles 
  Defines core methods used to implement callbacks.

  Callbacks functions by overriding the requested method with the new method 

Callback DB 

  
=end

module Sereth
  class CallbackDB
    @db = {}

    class << self
      # Retrieve the callback object
      def get(class_obj, func_name)
        key = class_obj.hash ^ func_name.hash
        return @db[key] if @db.has_key?(key)
        return []
      end

      def save(class_obj, func_name, op, block)
        key = class_obj.hash ^ func_name.hash
        @db[key] ||= CallbackDB.new(class_obj, func_name)
        @db[key].push(op, block)
      end
    end

    # Instanatiate a CallbackDB object to represent the current callback state
    def initialize(class_obj, func_name)
      @class_obj = class_obj
      @func_name = func_name
      @callbacks = []
    end

    # Return all function names defined for this invocation in a class
    def all_labels(class_obj, func_name)
      return [] if @callbacks.empty?
      ret = [get_label(0)]
      @callbacks.each_index {|index| ret.push(get_label(index + 1))}
      ret
    end

    # Generate the function name for the original method to be call-backed
    def orig_label
      get_label(0)
    end

    # Generate the function name for the next callback of a function in a class
    def next_label
      get_label(@callbacks.size + 1)
    end

    # Generate the function name for the current callback of a function in a class
    def cur_label
      get_label(@callbacks.size)
    end

    # Generate the function name of a callback given the function name and count
    def get_label(index)
      return "___callback_for_#{@func_name}_orig".to_sym if index == 0
      return "___callback_for_#{@func_name}_#{index}".to_sym
    end

    # Get the operation type
    def get_op(index)
      @callbacks[index].andand.first
    end

    def get_block(index)
      @callbacks[index].andand.last
    end

    # Yield the op, block, and function name, and super-function  of each callback
    def each
      @callbacks.each_index do |index|
        yield get_op(index), get_block(index), get_label(index + 1), get_label(index)
      end
    end

    private
    # Adds a specified callback is [op, block]. Only called from CallbackDB.save
    def add(*args)
      @callbacks.push(args)
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
    end

    def _inject_before_callback

    end

    def _inject_after_callback

    end

    def _inject_around_callback

    end

    # Generate a new method to handle this part of the callback
    def method_added(func_name)
      # Ignore methods being defined for the callback process
      return _precb_method_added if @_callback_active

      callback_db = CallbackDB.get(self, func_name)
      return _precb_method_added if !callback_db
      # Notify self that we are adding callbakcs

      @_callback_active = true


      # Need to define all the callbacks
      self.send :alias_method, callback_db.orig_label, func_name
      callback_db.each do |op, callback, callback_label, callto_label|
        case type
        when :before
          self.send :define_method, callback_label do |*args, &block|
            callback.call(*args, &block)
            self.send(callto_label, *args, &block)
          end
        when :after
          self.send :define_method, callback_label do |*args, &block|
            self.send(callto_label, *args, &block)
            callback.call(*args, &block)
          end
        when :around
          self.send :define_method, callback_label do |*args, &block|
            callback.call(*args) do
              self.send(callto_label, *args, &block)
            end
          end
        when :around_full
          self.send :define_method, callback_label do |*args, &block|
            callback.call({:args => args, :block => block}) do
              self.send(callto_label, *args, &block)
            end
          end
        else
          raise "Invalid callback type. Should never happen."
        end

        # Alias the current callback 
        self.send :alias_method, callback_label, func_name
      end
      
      # Finished adding callbacks
      @_callback_active = false
      return _precb_method_added
    end

    # Methods to populate the callback DB
    alias_shift_args :before_method, :_add_callback, :before
    alias_shift_args :after_method, :_add_callback, :after
    alias_shift_args :around_method, :_add_callback, :around
    alias_shift_args :around_method_full, :_add_callback, :around_full
    def _add_callback(op, func_name, &block)
      CallbackDB.save(self, func_name, op, block)
    end
  end
end