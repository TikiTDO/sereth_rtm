class Sereth::JsonPerspectives
  @perspectives = {}

  class << self
    def parse(path, name, instance)
      perspective = self.get(path, name)
      if perspective.present?
        Sereth::JsonGenerator.execute(perspective)
      else
        Sereth::JsonGenerator.error("Perspective not found: #{path}/#{name}")
      end
    end

    def generate(path, name, &block)
      key = [path, name]
      @perspectives[key] = []
      self.new(path, name, @perspectives[key])
      @perspectives[key].context_exec(&block)
    end

    def get(path, name)

    end
  end

  private
  def initialize(path, name, data_store)
    @path = path
    @name = name
    @data_store = data_store
  end

  public
  # Remove all unnecessary methods
  core_methods = %w(__id__ __send__ instance_eval instance_exec nil? is_a? class)
  instance_methods.each {|m| undef_method(m) unless core_methods.include?(m.to_s)}
  

  # Reuse an existing perspective, while overrideing unecessary data
  def use_perspective(path_or_name, name = nil)
    if name.present?
      path = path_or_name
    else
      path = @path
      name = path_or_name
    end

    @data_store.push([:override, path, name])
  end

  # Default handler for creating nodes and sub-nodes
  def method_missing(node_name, *args, &block)
    # Retrieve the expected data type
    expected = args.pop

    if block.present?
      new_data = []
      subnode = self.class.new(@path, @name, new_data)
      subnode.instance_exec(&block)
      @data_store.push([:sub_node, node_name, subnode])
    else
      @data_store.push([:command, node_name] + args)
    end
  end
end
