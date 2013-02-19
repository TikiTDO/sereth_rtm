=begin
# Callback System 
Implements before, after, and around callbacks for any requested function.

## Usage:
class Example
  include Sereth::Callback

  before_method :method_name do |args, block| 
    print 'b'
  end
  before_method :method_name do |args, block| 
    print 'b1'
  end
  after_method :method_name do |args, block| 
    print 'a' 
  end
  after_method :method_name do |args, block| 
    print 'a1' 
  end
  around_method :method_name do |runner, args, block| 
    print 'ar1' && runner.call && print 'ar2'
  end
  def method_name(*args, &block)
    print 'method'
  end
end

Example.new.method_name => ar1 b1 b method a a1 ar2

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
        key = [class_obj, func_name]
        return @db[key] if @db.has_key?(key)
        return []
      end

      def has?(class_obj, func_name)
        key = [class_obj, func_name]
        @db.has_key?(key)
      end

      def save(class_obj, func_name, op, block)
        key = [class_obj, func_name]
        @db[key] ||= CallbackDB.new(class_obj, func_name)
        @db[key].add(op, block)
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

    # Adds a specified callback is [op, block]. Only called from CallbackDB.save
    def add(*args)
      @callbacks.push(args)
    end
  end

  # Enables befre, after, and around callbacks for a given object. Ruby 1.9 only.
  module Callbacks
    # This module is only for extension
    def self.included(target)
      raise "The #{self} Module should only be extended, not included."
    end

    # Add the callback method added to the method_added stack
    def self.extended(target)
      target_class = class << target; self; end
      # Stack the method_added callback
      if target.method_defined?(:method_added)
        # Force module to override this method
        target.send :alias_method, :_precb_method_added, :method_added
        target_class.send :remove_method, :method_added
      else
        target_class.send :define_method, :_precb_method_added do  end
      end

      # Instantiate callback activity tracker
      target_class.send :instance_variable_set, :@_callback_active, false
    end

    # Generate a new method to handle this part of the callback
    def method_added(func_name)
      # Ignore methods being defined for the callback process
      return _precb_method_added if @_callback_active
      return _precb_method_added if !CallbackDB.has?(self, func_name)
      # Notify self that we are adding callbakcs
      @_callback_active = true
      callback_db = CallbackDB.get(self, func_name)
      

      # Need to define all the callbacks
      self.send :alias_method, callback_db.orig_label, func_name
      callback_db.each do |op, callback, callback_label, callto_label|
        case op
        when :before
          self.send :define_method, callback_label do |*args, &block|
            self.instance_exec(args, block, &callback)
            self.send(callto_label, *args, &block)
          end
        when :after
          self.send :define_method, callback_label do |*args, &block|
            self.send(callto_label, *args, &block)
            self.instance_exec(args, block, &callback)
          end
        when :around
          self.send :define_method, callback_label do |*args, &block|
            # Run the around callback
            #  The around callback should access the local methods
            #  The around callback shold yield to run the chain
            inst = self
            runner = proc do
              inst.send(callto_label, *args, &block)
            end
            self.instance_exec(runner, args, block, &callback)
          end
        else
          raise "Invalid callback type. Should never happen."
        end

        # Alias the current callback 
        self.send :alias_method, func_name, callback_label
      end
      
      # Finished adding callbacks
      @_callback_active = false
      return _precb_method_added
    end

    extend AliasArgs
    # Methods to populate the callback DB
    alias_shift_args :before_method, :_add_callback, :before
    alias_shift_args :after_method, :_add_callback, :after
    alias_shift_args :around_method, :_add_callback, :around
    def _add_callback(op, func_name, &block)
      CallbackDB.save(self, func_name, op, block)
    end
  end
end
