# The Template Manager API meant for external interface
class Sereth::TemplateManager
  attr_accessor :access

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