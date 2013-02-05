class Sereth::JsonSpecs
  @specs = {}
  @aliases = {}
  @alias_getter = lambda {}

  class << self
    def parse(inst, options)
      spec = self.get(path, name)
      if !spec.nil?
        Sereth::JsonGenerator.execute(spec)
      else
        Sereth::JsonGenerator.error("Perspective not found: #{path}/#{name}")
      end
    end

    def generate(path, name, &block)
      key = [path, name]
      @specs[key] = JsonSpecData.new
      self.new(path, name, @specs[key])
      @specs[key].context_exec(&block)
    end

    def get(path, name)
      @specs[path, name]
    end
  end
  
  # Remove all unnecessary methods
  core_methods = %w(__id__ __send__ instance_eval instance_eval nil? is_a? class)
  instance_methods.each {|m| undef_method(m) unless core_methods.include?(m.to_s)}

  private
  # Initialize the Spec path, name, and data store
  def initialize(path, name, data_store)
    @path = path
    @name = name
    @data_store = data_store
  end

  public
  ## Primary node creation mechanism
  # Tell the system that all function names are valid
  def respond_to_missing?(node_name, include_private = false)
    return true
  end

  # Default handler for creating nodes and sub-nodes
  def method_missing(node_name, type_or_proc = nil, proc = nil, *overflow, &block)
    proc = type_or_proc if proc.nil? && type_or_proc.kind_of?(Proc)
    type = type_or_proc if !type_or_proc.kind_of?(Proc)
    type ||= nil

    if !block.nil?
      # Generate sub-node

      # Handle object nodes
      subnode = self.class.new(@path, @name, @data_store.subnode!)
      subnode.instance_eval(&block)
    else
      # Add the command to the queue for execution
      @data_store.command!(node_name, type, proc)
    end
  end

  ## Extended Operations
  # Reuse an existing spec, while overrideing unecessary data
  def extends!(path_or_name, name = nil)
    name = path_or_name if name.nil?
    path = path_or_name  if !name.nil?
    path ||= @path 
      
    # Supply the extension info
    @data_store.extends!(path, name)
  end

  # Specifies a default value for a node
  def default!(node_name, proc_or_value)
    @data_store.default!(node_name, proc_or_value)
  end

  # Create a conditional handler to run in the context of the data instance under
  # operation. If this hanlder returns true run any supplied block.
  def cond!(cond_proc, &block)
    @data_store.cond!(cond_proc, &block)
  end

end
