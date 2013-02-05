class Sereth::JsonSpecData
  def initialize
    @spec = Object.new
    @override_spec = nil
    @command_queue = []
  end

  def collection!
  end

  # Queue up a node_name accessor
  def command!(node_name, type_or_proc, proc = nil)
    # Instantiate Parameters
    if proc
      type = type_or_proc
    else
      type = Object
      proc = type_or_proc
    end

    # Instantiate Names
    node_name = node_name.to_s
    node_method = node_name.to_sym

    # Add the command to the queue
    @command_queue.push(node) 

    # Generate the command on the spec object
    case type
    when Object
      # Handle normal objects
      command = command.to_sym
      class << spec
        # Define runner forproc handler
        define_method(command) do |inst|
          "{\"#{node_name}\": #{inst.instance_exec(&proc).to_json}"
          [node_name, inst.instance_exec(&proc)]
        end if proc
      end
    when Array
      # Handle collections

    end
  end

  def override!(spec)
    @override_spec = spec
  end

  def subnode!

  end

  def execute!(inst)
    ret = '{'
    # Run every command from the command queue
    for command in @command_queue
      ret += self.send(command, inst)
    end
    ret += '}'
  end

  # Pass undefined handlers to the override spec
  def method_missing(method, *args, &block)
    if @override_spec 
      @override_spec.send(method, *args, &block)
    else
      super
    end
  end
end
