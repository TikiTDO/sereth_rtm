module Sereth::JsonTunnel
  # Code generator to create functions that will extract an attribute from an object
  class Exports
    class << self
      ## Handler Generation
      # Create a handler for normal nodes
      def basic!(node_name, type, gen_proc, subnode = nil)
        # Handle normal objects
        if gen_proc
          # Proc based node value
          return proc do |inst, *extra|
            if subnode
              "\"#{node_name}\":#{subnode.export!(inst.instance_eval(&gen_proc))}"
            else
              "\"#{node_name}\":#{inst.instance_eval(&gen_proc).to_json}"
            end
          end
        else
          # Basic node value
          return proc do |inst, *extra|
            if subnode
              "\"#{node_name}\":#{subnode.export!(inst.send(node_name))}"
            else
              "\"#{node_name}\":#{inst.send(node_name).to_json}"
            end
          end
        end
      end

      # Create a handler for typed nodes
      def typed_basic!(node_name, type, gen_proc, subnode = nil)
        # Handle typed objects - Requires extra handling for schema generation
        if gen_proc
          # Proc based node value
          return proc do |inst, *extra|
            item = inst.instance_eval(&gen_proc)
            is_dummy = item.is_a?(DummyUtil)
            if item.is_a?(type) || item.nil? || is_dummy
              if subnode
                "\"#{node_name}\":#{subnode.export!(item)}"
              else
                if is_dummy
                  "\"#{node_name}\":#{item.to_json(type)}"
                else
                  "\"#{node_name}\":#{item.to_json}"
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
            is_dummy = item.is_a?(DummyUtil)
            if item.is_a?(type) || item.nil? || is_dummy
              if subnode
                "\"#{node_name}\":#{subnode.export!(item)}"
              else
                next "\"#{node_name}\":#{item.to_json(type)}" if is_dummy
                next "\"#{node_name}\":#{item.to_json}"
              end
            else
              raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
            end
          end
        end
      end

      # Create a handler for normal collections
      def collection!(node_name, type, gen_proc, subnode = nil)
        # Handle collections
        if gen_proc
          # Proc based array values
          return proc do |inst, *extra|
            pre_parse = inst.instance_eval(&gen_proc)
            pre_parse = [] if pre_parse.nil?
            pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

            if subnode
              parsed = pre_parse.map{|item| subnode.export!(item)}
            else
              parsed = pre_parse.map{|item| item.to_json}
            end

            "\"#{node_name}\":[#{parsed.join(",")}]"
          end
        else
          # Basic array values
          return proc do |inst, *extra|
            pre_parse = inst.send(node_name)
            pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

            if subnode
              parsed = pre_parse.map{|item| subnode.export!(item)}
            else
              parsed = pre_parse.map{|item| item.to_json}
            end

            "\"#{node_name}\":[#{parsed.join(",")}]"
          end
        end
      end

      # Create a handler for typed collections
      def typed_collection!(node_name, type, gen_proc, subnode = nil)
        # Handle collections
        if gen_proc
          # Proc based array values
          return proc do |inst, *extra|
            pre_parse = inst.instance_eval(&gen_proc)
            pre_parse = [] if pre_parse.nil?
            pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

            if subnode
              parsed = pre_parse.map do |item|
                next subnode.export!(item) if item.is_a?(type) || item.is_a?(DummyUtil)
                raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
              end
            else
              parsed = pre_parse.map do |item| 
                next item.to_json(type) if item.is_a?(DummyUtil)
                next item.to_json if item.is_a?(type)
                raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
              end
            end

            "\"#{node_name}\":[#{parsed.join(",")}]"
          end
        else
          # Basic array values
          return proc do |inst, *extra|
            pre_parse = inst.send(node_name)
            pre_parse = [pre_parse] if !pre_parse.kind_of?(Array)

            if subnode
              parsed = pre_parse.map do |item|
                next subnode.export!(item) if item.is_a?(type) || item.is_a?(DummyUtil)
                raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
              end
            else
              parsed = pre_parse.map do |item| 
                next item.to_json(type) if item.is_a?(DummyUtil)
                next item.to_json if item.is_a?(type)
                raise "Invalid type in JSON spec: Expected [#{type}] got #{item.class}"
              end
            end

            "\"#{node_name}\":[#{parsed.join(",")}]"
          end
        end
      end
    end
  end
end