# The Template Manager API meant for external interface
class Sereth::TemplateManager
  attr_accessor :access

  class << self
    def method_missing?(name, *args, &block)
      @inst ||= self.new
      @inst.send(name, *args, &block)
    end
  end

  def initialize(mode = :development)
    @mode = mode
    @sprockets = Context.get(:sprockets)
    case mode
    when :development
      # Development Mode :: Query Manifest + Recompile each request
    when :production
      # Production Mode :: Query Manifest Only
    else
      raise "Invalid Mode"
    end    
  end

  # Configure the template location
  def path=(path)
    @path = Pathname.new(path)

    @manifest_path = @path.join('manifest.rb')
    @raw_path = @path.join('raw')
    @cached_path = @path.join('cached')

    # Load the manifest if it exists
    @manifest = Manifest.load(@manifest_path) if @manifest.exist?
  end

  # Get js code representing the template
  def get_template(path)
    if @mode == :production
      @manifest.serve(path)
    else
      @manifest.parse(path) if !@manifest.provides?(path)  
      @manifest.serve(path)
    end
  end
end

# Manifest - Stores Templates. Batch templates operations.
# Template - Stores Template Instances
# Parser - Generates Templates
# Generator? - Creates parsed template code