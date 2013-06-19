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
    case mode
    when :development
      # Development Mode :: Query Manifest + Recompile each request
    when :production
      # Production Mode :: Query Manifest Only
    end    
  end

  # Configure the template location
  def path=(path)
    @path = Pathname.new(path)

    @manifest_path = @path.join('manifest.rb')
    @raw_path = @path.join('raw')
    @cached_path = @path.join('cached')

    # Load the manifest if it exists
    @manifest = Manifest::DSL.load(@manifest_path) if @manifest.exist?
    

    # Configure Raw locations
  end

  # Read the directory, and compile it
  def parse(directory)
    # Sprockets initialization
  end

  # Get js code representing the template
  def get_template(path)
    # Query the sprockets system
  end

  # Get data out of the manifest
  def manifest(path)
    
  end

  # Parse the data source in order to generate the manifest
  def parse

  end
end

# Manifest - Stores Templates. Batch templates operations.
# Template - Stores Template Instances
# Parser - Generates Templates
# Generator? - Creates parsed template code