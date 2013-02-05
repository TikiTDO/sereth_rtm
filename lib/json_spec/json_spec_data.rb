module Sereth
  class JsonSpecData
    def initialize
      @spec = Object.new
      @spec_class = class << @spec; self; end
      @override_spec = nil
      @command_queue = []
    end

    # Queue up a node_name accessor for standard attributes
    def command!(node_name, type, proc, subnode = nil)
      # Add the command to the queue
      @command_queue.delete(node_name)
      @command_queue.push(node_name)

      # Generate the command on the spec object
      generator = nil
      if type.nil?
        # Handle normal objects
        if proc
          # Proc based node value
          generator = Proc.new do |inst|
            if subnode
              "\"#{node_name}\": #{subnode.execute!(inst.instance_eval(&proc))}"
            else
              "\"#{node_name}\": #{inst.instance_eval(&proc).to_json}"
            end
          end
        else
          # Basic node value
          generator = Proc.new do |inst|
            if subnode
              "\"#{node_name}\": #{subnode.execute!(inst.send(node_name))}"
            else
              "\"#{node_name}\": #{inst.send(node_name).to_json}"
            end
          end
        end
      elsif type == Array
        # Handle collections
        if proc
          # Proc based array values
          generator = Proc.new do |inst|
            pre_parse = inst.instance_eval(&proc)
            pre_parse = [] if pre_parse.nil?
            pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

            if subnode
              parsed = pre_parse.map{|item| "#{subnode.execute!(item)}"}
            else
              parsed = pre_parse.map{|item| "#{item.to_json}"}
            end

            "\"#{node_name}\": [#{parsed.join(",")}]"
          end
        else
          # Basic array values
          generator = Proc.new do |inst|
            pre_parse = inst.send(node_name)
            pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

            if subnode
              parsed = pre_parse.map{|item| "#{subnode.execute!(item)}"}
            else
              parsed = pre_parse.map{|item| "#{item.to_json}"}
            end

            "\"#{node_name}\": [#{parsed.join(",")}]"
          end
        end
      else
        # Handle invalid types
        raise "Invalid json_spec type: #{type}"
      end
      @spec_class.send :define_method, node_name, &generator
    end

    # Iterate over all commands defined in this object, and all commands in super-objects
    def each_command(complete = {}, &block)
      @command_queue.each do |command|
        block.call(command) if !complete[command]
        complete[command] = true
      end

      @override_spec.each_command(complete, &block) if @override_spec
    end

    def override!(spec)
      @override_spec = spec
    end

    def execute!(inst)
      ret = '{'
      ph = ""
      # Run every command from the command queue
      for command in @command_queue
        ret += ph + @spec.send(command, inst)
        ph = ", "
      end
      ret += '}'
    end

    def respond_to_missing?(node_name, include_private = false)
      @override_spec.respond_to?(node_name)
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
end
