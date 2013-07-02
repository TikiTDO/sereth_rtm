# Parser plugins allow libraries to plugin to the parsing process and call
# other ruby code. Executed plugins are stored as part of the DataInst metadata
class Sereth::TemplateManager::ParserPlugin
  @@position = Struct.new(:node, :access, :index)
  ## Callbacks
  class << self
    # Fired at the start of parsing
    def on_parse(&block)
    end

    # Fired when entering a node
    def on_entry(in_state: nil, &block)
    end

    # Fired when entering a new state
    def on_state(state, &block)
    end
  end

  def initialize(ast)
    @root = ast
    @parent = []
    @postion = @@position.new(ast, nil, 0)
    @state = []
  end

  ## State Operation
  # Enter a new state
  def state(name)
    @state.push(name)
  end

  # Return to a previous state
  def pop_state
    @state.pop
  end

  # Check if name is the current, or one of the parent states
  def is_state?(name)
    @state.include?(name)
  end

  # Move up to this node's parent
  def up
    @position = @parent.pop
    raise "Some parser plugin is going too far up" if @position.nil?
  end

  # Move to this node's next sibling
  def next_node
    @position.index += 1
  end

  # Move to this node's named child
  def down(index = nil)
    @parent.push(@@position.new(@node, @index))
    @node = @node.send(index)
  end

  def position

  end

  # Return the index of all of this node's children
  def ls_down
  end

  # Get the node pointed to by the current position
  def get
    if @position.access
      data = @node.send(@position.access) 
    else
      data = @node
    end
  end

  # 
  private; def enter(node)
    
  end; public
end
