class Sereth::JsonSpecData
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
    @spec = Object.new
    @spec_class = class << @spec; self; end
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
  def command!(node_name, type, gen_proc, subnode = nil)
    # Add the command to the queue
    @command_queue.delete(node_name)
    @command_queue.push(node_name)

    # Generate the command on the spec object
    generator = nil
    if type.nil? 
      generator = JsonSpecGetters.basic!(node_name, type, gen_proc, subnode)
    elsif type == Array
      generator = JsonSpecGetters.collection!(node_name, type, gen_proc, subnode)
    elsif type.is_a?(Class)
      generator = JsonSpecGetters.typed_basic!(node_name, type, gen_proc, subnode)
    elsif type.is_a?(Array) && type.first == Array
      generator = JsonSpecGetters.typed_collection!(node_name, type[1], gen_proc, subnode)
    else
      # Handle invalid types
      raise "Invalid json_spec type: #{type}"
    end

    # Declare the generator method in the data object
    @spec_class.send :define_method, node_name, &generator
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
        inst = JsonDummy.new('Conditional')
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

  extend Callbacks
  # Handle caching
  around_method :execution_inside! do |runner, args|
    if JsonSpecCache.enabled? 
      cache = JsonSpecCache.retrieve(*args)
      cache = JsonSpecCache.store(runner.call, *args) if !cache
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
