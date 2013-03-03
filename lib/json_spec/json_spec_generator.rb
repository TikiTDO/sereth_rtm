module Sereth
  class JsonSpecGenerator
    @specs = {}
    @schema = nil
    @aliases = {}
    @alias_getter = lambda {}

    class << self
      def parse(path, name, inst)
        spec = self.get(path, name)
        if !spec.nil?
          spec.execute!(inst)
        else
          #Sereth::JsonSpecGenerator.error("Perspective not found: #{path}/#{name}")
          raise "No Spec"
        end
      end

      def generate(path, name, &block)
        key = [path, name]
        @specs[key] = JsonSpecData.new

        self.new(path, name, @specs[key]).instance_eval(&block)
      end

      def get(path, name)
        @specs[[path, name]]
      end

      def each(path = nil, &block)
        if path.nil?
          @specs.each(&block)
        else
          @specs.each do |k, v|
            block.call(k.last, v) if k.first == path
          end
        end
      end
    end
    
    # Remove all unnecessary methods
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
    # Tell the system that all function names are valid
    def respond_to_missing?(node_name, include_private = false)
      return true
    end

    def generate_subnode(&block)
      # Generate and populate sub-node 
      subnode = Sereth::JsonSpecData.new
      self.class.new(@path, @name, subnode).instance_eval(&block)
      return subnode
    end


    # Default handler for creating nodes and sub-nodes
    def method_missing(node_name, type_or_proc = nil, proc = nil, *overflow, &block)
      # Initialize parameters
      if type_or_proc.kind_of?(Proc) || type_or_proc.kind_of?(Symbol)
        raise "Lambdas not support" if proc && proc.lambda?
        proc = type_or_proc if proc.nil?
      else
        type = type_or_proc
      end      
      type ||= nil

      # Initialize optional sub-node
      subnode = generate_subnode(&block) if !block.nil?
      subnode ||= nil

      # Add the command to the queue for execution
      @data_store.command!(node_name, type, proc, subnode)
    end


    # Create a conditional handler to run in the context of the data instance under
    # operation. If this hanlder returns true run any supplied block.
    def if!(cond_proc, &block)
      # Initialize optional sub-node
      subnode = generate_subnode(&block) if !block.nil?
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
        
      # Supply the extension info
      @data_store.extends!(self.class.get(path, name))
    end
  end
end