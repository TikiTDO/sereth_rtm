# Shiv Interface for RKelly objects
class Sereth::TemplateManager::RKellyWrapper
  @@position = Struct.new(:key, :index)

  class << self
    def begin(source_node)
      # Initialize to the first SourceElement in the Program SourceElements
      if @node.is_a? RKelly::Nodes::SourceElementsNode
        first_node = @node.value[0]
        first_pos = @@position.new(:value, 0)
        return nil if !first_node
        return self.new(first_node, source_node, first_pos)
      else
        raise "Must begin parse from a SourceElementsNode"
      end
    end
  end

  # Parent wrapper should always be accessible
  attr_accessor :parent

  # Restrict creation to internal managers
  protected; def initialize(node, parent = nil, parent_position = nil)
    @node = node
    @parent = parent
    @parent ||= self.class.new
    @parent_position = parent_position
  end; public

  # Query the current node for a (possibly indexed) value
  def query(key, index = 0)
    # Ensure the requested index actually exists
    key = key.to_sym
    return nil if !@node.respond_to?(key)
    ret = @node.send(key)

    # Return the queried value
    return ret[index] if ret.is_a?(Array)
    return nil if index != 0
    return ret
  end

  # Check if a node is of a given RKelly type
  def node_is?(node, name)
    node.class.name == "RKelly::Nodes::#{name}Node"
  end

  def source_element?
    return @node.is_a? RKelly::Nodes::SourceElementsNode
  end

  def has_next_sibling?
    @parent.has_next_child(@parent_position)
  end

  def next_sibling
    return @parent.next_child(@parent_position) if @parent_position
    return nil
  end

  def has_next_child?(position)
    !query(positon.key, position.index + 1).nil?
  end

  def next_child(position)
    node = query(position.key, position.index + 1)
    return nil if !node
    return self.class.new(node)
  end

  def go(key)
    node = query(key)
    return self.class.new(node, self, @@postion.new(key, 0))
  end

  # Retrieve the actual operational node (as opposed to organizational)
  def get_actual
  end

  # Call Interface
  def is_call?
    node = @node
    node = node.value if node_is?(node, "ExpressionStatement")
    return node.is_a?(RKelly::Nodes::FunctionCallNode)
  end

  def call_name
    node = @node
    node = node.value if node_is?(node, "ExpressionStatement")
    
  end

  def call_argument(number)

  end

  def to_function_body
  end

  def to_function_args
  end

  # Move to this node's named child
  def down(index = nil)
    @parent.push(@@position.new(@node, @index))
    @node = @node.send(index)
    return self.class.new(new_node)
  end

  def key

  end
  
  def index

  end
end

