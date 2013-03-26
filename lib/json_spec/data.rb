module Sereth::JsonSpec
  class Data
    # Spec Data Storage
    @specs = {}
    @schema = nil
    @aliases = {}
    @alias_getter = lambda {}

    class << self
      def import(path, name, inst, spec)
        raise 'TODO'
      end

      def export(path, name, inst)
        spec = self.get(path, name)
        if !spec.nil?
          spec.export!(inst)
        else
          #Sereth::JsonSpecGenerator.error("Perspective not found: #{path}/#{name}")
          raise "No Spec"
        end
      end

      def generate(path, name, &block)
        data_inst = self.new
        Generator.new(path, name, @specs[key]).instance_eval(&block)

        @specs[[path, name]] = data_inst
      end

      def get(path, name)
        @specs[[path, name]]
      end

      # Iterate over each spec as (spec_path, spec_name, value) or (spec_name, value)
      def each(path = nil, &block)
        @specs.each do |k, v|
          next if !path.nil? && k.first != path
          block.call(v) if block.arity == 1
          block.call(k.last, v) if block.arity == 2
          block.call(k.first, k.last, v)
        end
      end
    end

    ## Spec Initialization
    # Receive responder queries from extending spec
    def respond_to_missing?(node_name)
      @spec.send(:respond_to_missing?, node_name)
    end

    # Receive handler requets from extending spec
    def method_missing(method, *args, &block)
      @spec.send(method, *args, &block)
    end

    def initialize
      @raw = {}
      # Holds the methods that will be executed to generate a spec
      @spec = Object.new
      # Used to define methods on @spec
      @spec_class = class << @spec; self; end

      # Holds the procs which will be used to update an instance, may be subset of full spec
      @setters = {}

      # Data for execution.
      @command_queue = []
      @if_count = 0
      # Array, since reference to spec needs to be available in a different context
      @extended_spec = []
      local_extended_spec = @extended_spec

      # Query responders from extended spec
      @spec_class.send :define_method, :respond_to_missing? do |node_name|
        local_extended_spec.first.respond_to?(node_name)
      end

      # Pass undefined handlers to the extended spec
      @spec_class.send :define_method, :method_missing do |method, *args, &block|
        if !local_extended_spec.empty?
          local_extended_spec.first.send(method, *args, &block)
        else
          super(method, *args, &block)
        end
      end
    end

    # Queue up a node_name accessor for standard attributes
    # Expectation: node_name always originates from a symbol, so no need to escape
    def command!(node_name, array, subnode = nil, type: nil, get: nil, set: nil)
      # Add the command to the queue
      @command_queue.delete(node_name)
      @command_queue.push(node_name)

      # Generate the command on the spec object
      exporter = nil

      if array && type.nil?
        exporter = Exports.collection!(node_name, type, get, subnode)
      elsif array && type.is_a?(Class)
        exporter = Exports.typed_collection!(node_name, type, get, subnode)
      elsif type.nil? 
        exporter = Exports.basic!(node_name, type, get, subnode)
      elsif type.is_a?(Class)
        exporter = Exports.typed_basic!(node_name, type, get, subnode)
      else
        # Handle invalid types
        raise "Invalid json_spec type: #{type}"
      end

      # Generate the importer object
      if set.is_a?(Proc) || set.is_a?(Symbol)
        @setters[node_name] = set
      end

      # Declare the generator method in the data object
      @spec_class.send :define_method, node_name, &exporter
      @raw[node_name] = type
    end
    
    # Declare a conditional executior with execution break-in
    def if!(cond_proc, subnode)
      @if_count += 1
      if_name = "__json_conditional_#{@if_count}__".to_sym
      @command_queue.push(if_name)

      # Conditionals should not 
      conditional = proc do |inst, *extra|
        if inst.is_a?(JsonDummy)
          inst = DummyUtil.new('Conditional')
          result = true
        else
          result = cond_proc.call(inst)
        end
        return subnode.export_inside!(inst) if result && subnode
        return nil
      end

      @spec_class.send :define_method, if_name, &conditional
      @raw[if_name] = subnode
    end

    # Declare a super-spec to extend this from
    def extends!(spec)
      @extended_spec.clear.push(spec)
    end

    ## Spec Execution
    # Iterate over all commands defined in this object, and all commands in super-objects
    def each_command!(complete = {}, &block)
      @command_queue.each do |command|
        block.call(command, complete) if !complete[command]
        complete[command] = true
      end

      @extended_spec.first.each_command!(complete, &block) if !@extended_spec.empty?
    end

    extend Sereth::Callbacks
    # Handle caching
    around_method :execution_inside! do |runner, args|
      if Cache.enabled? 
        cache = Cache.retrieve(*args)
        cache = Cache.store(runner.call, *args) if !cache
      else
        cache = runner.call
      end
      cache
    end

    # Execute the spec for the given instance, and return the raw results
    def export_inside!(inst)
      ret = ""
      ph = ""
      # Run every command from the command queue
      each_command! do |command, complete|
        res = @spec.send(command, inst, complete)
        ret << ph << res if res
        ph = ", " if ph == ""
      end
    end

    # Execute the spec for the given instance, and place the result in an object
    def export!(inst)
      '{' << export_inside!(inst) << '}'
    end
  end
end