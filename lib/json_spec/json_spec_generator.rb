module Sereth
  class JsonSpecGenerator
    # Remove all potentially unnecessary methods
    core_methods = %w(__id__ __send__ object_id instance_eval methods class nil? is_a?
      respond_to?)
    instance_methods.each {|m| undef_method(m) unless core_methods.include?(m.to_s)}

    private
    # Initialize the Spec path, name, and data store
    def initialize(path, name, data_store)
      @path = path
      @name = name
      @data_store = data_store
    end

    public
    ## Primary node creation mechanism
    # Generate a new JsonSpecData instance, and populates it with a
    def generate_subnode!(&block)
      # Generate and populate sub-node 
      subnode = Sereth::JsonSpecData.new
      self.class.new(@path, @name, subnode).instance_eval(&block)
      return subnode
    end

    # Tell the system that all function names are valid
    def respond_to_missing?(node_name, include_private = false)
      return true
    end

    # Default handler for creating nodes and sub-nodes
    def method_missing(node_name, sym_or_arr = nil, sym = nil, *_,
                        type: nil, get: nil, set: nil, &block)
      # Determine if the data is an array
      arr = (sym_or_arr == Array)
      # Get symbol param shorthand
      sym = sym_or_arr if sym_or_arr.kind_of?(Symbol)
      # The data getter will query the function named by the specified getter symbol if set
      get ||= sym if sym.is_a?(Symbol)
      # The data getter will fall back to querying the same function as the node name
      get ||= node_name

      if block
        # Objects do not support extended options. Use keys in the subnode.
        subnode = generate_subnode!(&block) if !block.nil?
        subnode ||= nil
        @data_store.command!(node_name, arr, subnode)
      else
        raise "Getter must not be a lambda" if get.is_a?(Proc) && get.lambda?
        raise "Setter must not be a lambda" if set.is_a?(Proc) && set.lambda?
        raise "Type must be a class" if !type.nil? && !type.is_a?(Class)
        @data_store.command!(node_name, arr, subnode, type: type, get: get, set: set)
      end
    end

    # Create a conditional handler to run in the context of the data instance under
    # operation. If this hanlder returns true run any supplied block.
    def if!(cond_proc, &block)
      # Initialize optional sub-node
      subnode = generate_subnode!(&block) if !block.nil?
      subnode ||= nil

      # Add the subnode to the queue for execution
      @data_store.if!(cond_proc, subnode)
    end
    
    ## Extended Operations
    # Direct access to node creator
    def override!(node_name, *args, &block)
      self.method_missing(node_name.to_sym, *args, &block)
    end

    # Reuse an existing spec, while overrideing unecessary data
    def extends!(path_or_name, name = nil)
      path = path_or_name if !name.nil?
      path ||= @path 

      name = path_or_name if name.nil?
        
      # Supply the extension info to underlying data object
      @data_store.extends!(JsonSpecData.get(path, name))
    end
  end
end