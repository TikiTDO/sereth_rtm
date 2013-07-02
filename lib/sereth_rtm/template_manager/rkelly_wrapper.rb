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

  def source_element?
    return @node.is_a? RKelly::Nodes::SourceElementsNode
  end

  # If this node 
  def next_sibling
    return @parent.next_child(@parent_position) if @parent_position
    return nil
  end

  def next_child(position)
    node = @node.send(position.key)[position.index + 1]
    return nil if !node
    return self.class.new(node)
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

