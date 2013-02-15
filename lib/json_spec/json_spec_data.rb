module Sereth
  class JsonSpecData
    # Allow use of before_method, after_method, and around_method callbacks
    extend Callbacks

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

    ## Handler Generation
    private
    # Create a handler for normal nodes
    def generate_basic!(node_name, type, gen_proc, subnode = nil)
      # Handle normal objects
      if gen_proc
        # Proc based node value
        return proc do |inst, *extra|
          if subnode
            "\"#{node_name}\": #{subnode.execute!(inst.instance_eval(&gen_proc))}"
          else
            "\"#{node_name}\": #{inst.instance_eval(&gen_proc).to_json}"
          end
        end
      else
        # Basic node value
        return proc do |inst, *extra|
          if subnode
            "\"#{node_name}\": #{subnode.execute!(inst.send(node_name))}"
          else
            "\"#{node_name}\": #{inst.send(node_name).to_json}"
          end
        end
      end
    end

    # Create a handler for typed nodes
    def generate_typed_basic!(node_name, type, gen_proc, subnode = nil)
      # Handle typed objects - Requires extra handling for schema generation
      if gen_proc
        # Proc based node value
        return proc do |inst, *extra|
          item = inst.instance_eval(&gen_proc)
          is_dummy = item.is_a?(JsonDummy)
          if item.is_a?(type) || item.nil? || is_dummy
            if subnode
              "\"#{node_name}\": #{subnode.execute!(item)}"
            else
              if is_dummy
                "\"#{node_name}\": #{item.to_json(type)}"
              else
                "\"#{node_name}\": #{item.to_json}"
              end
            end
          else
            raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
          end
        end
      else
        # Basic node value
        return proc do |inst, *extra|
          item = inst.send(node_name)
          is_dummy = item.is_a?(JsonDummy)
          if item.is_a?(type) || item.nil? || is_dummy
            if subnode
              "\"#{node_name}\": #{subnode.execute!(item)}"
            else
              next "\"#{node_name}\": #{item.to_json(type)}" if is_dummy
              next "\"#{node_name}\": #{item.to_json}"
            end
          else
            raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
          end
        end
      end
    end

    # Create a handler for normal collections
    def generate_collection!(node_name, type, gen_proc, subnode = nil)
      # Handle collections
      if gen_proc
        # Proc based array values
        return proc do |inst, *extra|
          pre_parse = inst.instance_eval(&gen_proc)
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
        return proc do |inst, *extra|
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
    end

    # Create a handler for typed collections
    def generate_typed_collection!(node_name, type, gen_proc, subnode = nil)
      # Handle collections
      if gen_proc
        # Proc based array values
        return proc do |inst, *extra|
          pre_parse = inst.instance_eval(&gen_proc)
          pre_parse = [] if pre_parse.nil?
          pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

          if subnode
            parsed = pre_parse.map do |item|
              next subnode.execute!(item) if item.is_a?(type) || item.is_a?(JsonDummy)
              raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
            end
          else
            parsed = pre_parse.map do |item| 
              next item.to_json(type) if item.is_a?(JsonDummy)
              next item.to_json if item.is_a?(type)
              raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
            end
          end

          "\"#{node_name}\": [#{parsed.join(",")}]"
        end
      else
        # Basic array values
        return proc do |inst, *extra|
          pre_parse = inst.send(node_name)
          pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

          if subnode
            parsed = pre_parse.map do |item|
              next subnode.execute!(item) if item.is_a?(type) || item.is_a?(JsonDummy)
              raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
            end
          else
            parsed = pre_parse.map do |item| 
              next item.to_json(type) if item.is_a?(JsonDummy)
              next item.to_json if item.is_a?(type)
              raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
            end
          end

          "\"#{node_name}\": [#{parsed.join(",")}]"
        end
      end
    end

    public
    # Queue up a node_name accessor for standard attributes
    # Expectation: node_name always originates from a symbol, so no need to escape
    def command!(node_name, type, gen_proc, subnode = nil)
      # Add the command to the queue
      @command_queue.delete(node_name)
      @command_queue.push(node_name)

      # Generate the command on the spec object
      generator = nil
      if type.nil? 
        generator = generate_basic!(node_name, type, gen_proc, subnode)
      elsif type == Array
        generator = generate_collection!(node_name, type, gen_proc, subnode)
      elsif type.is_a?(Class)
        generator = generate_typed_basic!(node_name, type, gen_proc, subnode)
      elsif type.is_a?(Array) && type.first == Array
        generator = generate_typed_collection!(node_name, type[1], gen_proc, subnode)
      else
        # Handle invalid types
        raise "Invalid json_spec type: #{type}"
      end

      # Declare the generator method in the data object
      @spec_class.send :define_method, node_name, &generator
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
        return subnode.execute_inside!(inst) if result && subnode
        return nil
      end

      @spec_class.send :define_method, if_name, &conditional
    end

    # Declare a super-spec to extend this from
    def extends!(spec)
      @extended_spec.clear.push(spec)
    end

    # Iterate over all commands defined in this object, and all commands in super-objects
    def each_command!(complete = {}, &block)
      @command_queue.each do |command|
        block.call(command, complete) if !complete[command]
        complete[command] = true
      end

      @extended_spec.first.each_command!(complete, &block) if !@extended_spec.empty?
    end

    # Handle caching
    around_method :execution_inside! do |inst|
      to_cache = false
      if to_cache
        # Always reload instances if a changed status cannot be detected
        reload = inst.respond_to?(:should_reload?) ? inst.should_reload? : true

        cache = nil
        cache = yield if reload
        cache ||= JsonSpecCache.get_cached(self, inst)

        # Handle cached schemas
        JsonSpecCache.save(self, inst, cache) if reload
      else
        cache = yield
      end

      cache
    end

    # Execute the spec for the given instance, and return the raw results
    def execute_inside!(inst)
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
    def execute!(inst)
      '{' << execute_inside!(inst) << '}'
    end
  end
end
