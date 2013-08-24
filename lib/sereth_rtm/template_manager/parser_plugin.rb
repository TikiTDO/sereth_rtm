# Parser plugins allow libraries to plugin to the parsing process and call
# other ruby code. Executed plugins are stored as part of the DataInst metadata
class Sereth::TemplateManager::ParserPlugin
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
    # Initial environment
    #  Should be able to navigate the root SourceElementsNode
    #  Current node = fist child of the SEN
    #  
    raise 'Must pased from a SourceElementNode' if !ast.is_a?(SourceElementNode)
    @root = ast
    
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
