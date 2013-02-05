class Sereth::JsonSpecs
  @specs = {}
  @aliases = {}
  @alias_getter = lambda {}

  class << self
    def parse(inst, options)
      spec = self.get(path, name)
      if spec.present?
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
  core_methods = %w(__id__ __send__ instance_eval instance_exec nil? is_a? class)
  instance_methods.each {|m| undef_method(m) unless core_methods.include?(m.to_s)}

  private
  # Initialize the Spec path, name, and data store
  def initialize(path, name, data_store)
    @path = path
    @name = name
    @data_store = data_store
  end

  public
  # Reuse an existing spec, while overrideing unecessary data
  def override!(path_or_name, name = nil)
    if name.present?
      path = path_or_name
    else
      path = @path
      name = path_or_name
    end

    override_spec

    @data_store.override!(path, name)
  end

  # Default handler for creating nodes and sub-nodes
  def method_missing(node_name, type_or_proc = nil, *args, &block)
    # Retrieve the expected data type
    expected = args.pop

    if block.present?
      # If a block is present
      subnode = self.class.new(@path, @name, @data_store.subnode!)
      subnode.instance_exec(&block)
    else
      @data_store.command!(node_name, *args)
    end
  end
end
