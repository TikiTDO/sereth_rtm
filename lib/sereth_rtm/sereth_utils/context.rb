# Contexts connect instances to instances
#  Configured at the class level

# Goal is to print contexts to see what's interacting with what
#  Also may change context to add new features
#  Contexts connect to javascript instances through websockets
#    Can have socket context, connected on one end to a client, and on the other bound to things
#    it is allowed to do

# Primary context is bound to Context class
#   Sub-contexts are bound to threads of execution


class ClientStore
  # Maybe something to do with superclasses for org?

  # Register ClientStore in the context database, under store context
  self.register_context(:store_context)

  # Instantiating a class generates a context int (before initialize)
  def process_script(file)
    # Link the instance context as responsible for the tag
    # All context requests for :store_context in the local realm will map to this inst
    #
    context.link tag_from_file(file)
  end
end

class ProcessModel
  parent_context.register(:process)

  def get_client
    context.get_link(:client_context) # Gets process entry from the client context tree
    context.get_tag(:step) # Gets the StepModel from the process context tree
  end
end

#-----------
class ClientStore

end

class Template

end

context.reserve # Prevent sub-contexts from overriding this name

context.tag_rule # Handle tagging rule. May need extra config
context.tag # Assign a tag to the context

context.to # Navigate to a context based on name or tag

system_context # or just context outside any classes
root_context # Get the context handler
parent_context # Get the context container for an inst
task_context # Access the thread local context object
context # Access the code local context object

class Example
  # Add a class to a context
  contextualize(name, parent_context: nil)
  # Ctx Tree: (name)

  # Link types - Direct

  context.link(:name, target_context, type: (:all or :indirect))

  def initialize
    # Ctx Tree: (name (inst_1,2,3...))
    context # => inst_x

    # Link connects classes and generic types
    context.to(:name)
  end
end



# Context bound to thread
# May be threads without a context
# 

# Half assed context replacement
class Sereth::Context
  class << self
    # The top context stores system level details, and exports config to children
    def top
      @top ||= Context.new
    end

    # Start a new context from the top
    def wipe
      top.generate
    end

    def current
      ctx = Thread.current[:context]
      ctx = top.generate if !ctx
      return ctx
    end

    # Shorthand alias to query current context instance get
    alias_method :[], :get
    def get(key)
      current.get(key)
    end

    # Shorthand alias to query current context instance set
    alias_method :[]=, :set
    def set(key, value)
      current.set(key, value)
    end
  end

  # Create a new context from the current one
  def generate
    Thread.current[:context] = Context.new(self)
  end

  # Create a new context. Parents not exposed
  def initialize(parent = nil)
    @parent = parent
    @data = {}
  end

  # Storage retreival
  alias_method :[], :get
  def get(key)
    # Query parents if value not found
    if !(res = @data[key]).nil?
      return res
    elsif !parent.nil? 
      return parent.get(key)
    end
    # Defaults to nil if value not found
    return nil
  end

  # Storage assignment
  alias_method :[]=, :set
  def set(key, value)
    @data[key] = value
  end
end