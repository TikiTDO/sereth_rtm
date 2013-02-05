class Sereth::JsonSpecData
  def initialize
    @spec = Object.new
    @override_spec = nil
    @command_queue = []
  end

  def collection!
  end

  # Queue up a node_name accessor
  def command!(node_name, type, proc)
    # Add the command to the queue
    @command_queue.push(node_name)

    # Generate the command on the spec object
    case type
    when nil
      # Handle normal objects
      class << @spec
        # Define runner forproc handler
        if proc
          define_method(node_name) do |inst|
            "{\"#{node_name}\": #{inst.instance_eval(&proc).to_json}"
          end
        else
          define_method(node_name) do |inst|
            "{\"#{node_name}\": #{inst.send(node_name).to_json}"
          end
        end
      end
    when Array
      # Handle collections
      class << @spec
        # Define runner forproc handler
        if proc
          define_method(node_name) do |inst|
            pre_parse = inst.instance_eval(&proc)
            pre_parse = [] if pre_parse.nil?
            pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

            parsed = pre_parse.map{|item| "#{item.to_json}"}
            "{\"#{node_name}\": [#{parsed.join(",")}]"
          end
        else
          define_method(node_name) do |inst|
            pre_parse = inst.send(node_name)
            pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

            parsed = pre_parse.map{|item| "#{item.to_json}"}
            "{\"#{node_name}\": [#{parsed.join(",")}]"
          end
        end
      end
    else
      # Handle invalid types
      raise "Invalid json_spec type: #{type}"
    end
  end

  def object!(node_name, type, proc)

  end

  # Iterate over all commands defined in this object, and all commands in super-objects
  def each_command

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

  def respond_to_missing?(node_name, include_private = false)

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
