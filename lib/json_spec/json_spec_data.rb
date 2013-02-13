module Sereth
  class JsonSpecData
    def initialize
      @spec = Object.new
      @spec_class = class << @spec; self; end
      @command_queue = []
      @if_count = 0
      # Array, since reference to spec needs to be available in a different context
      @extended_spec = []


      # Spec extension helpers
      @spec_class.send :define_method, :respond_to_missing? do |node_name|
        @extended_spec.respond_to?(node_name)
      end

      local_extended_spec = @extended_spec
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
              parsed = pre_parse.map{|item| subnode.execute!(item)}
            else
              parsed = pre_parse.map{|item| item.to_json}
            end

            "\"#{node_name}\": [#{parsed.join(",")}]"
          end
        else
          # Basic array values
          generator = Proc.new do |inst|
            pre_parse = inst.send(node_name)
            pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

            if subnode
              parsed = pre_parse.map{|item| subnode.execute!(item)}
            else
              parsed = pre_parse.map{|item| item.to_json}
            end

            "\"#{node_name}\": [#{parsed.join(",")}]"
          end
        end
      elsif type.kind_of?(Class)
        # Handle typed objects
      else
        # Handle invalid types
        raise "Invalid json_spec type: #{type}"
      end
      @spec_class.send :define_method, node_name, &generator
    end

    # Declare a super-spec to extend this from
    def extends!(spec)
      @extended_spec.clear.push(spec)
    end

    def if!(cond_proc, &block)
      @if_count += 1
      if_name = "json_cond_#{@if_count}".to_sym
      @command_queue.push(if_name)

      conditional = proc do |inst|
        result = cond_proc.call(inst)
        block.call if result && block
      end

      @spec_class.send :define_method, if_name, &conditional
    end

    # Iterate over all commands defined in this object, and all commands in super-objects
    def each_command(complete = {}, &block)
      @command_queue.each do |command|
        block.call(command) if !complete[command]
        complete[command] = true
      end

      @extended_spec.first.each_command(complete, &block) if !@extended_spec.empty?
    end

    # 
    def execute!(inst)
      ret = '{'
      ph = ""
      # Run every command from the command queue
      each_command do |command|
        res = @spec.send(command, inst)
        ret << ph << res if res
        ph = ", " if ph 
      end
      ret << '}'
    end

    def respond_to_missing?(node_name)
      @spec.send(:respond_to_missing?, node_name)
    end

    def method_missing(method, *args, &block)
      @spec.send(method, *args, &block)
    end
  end
end
