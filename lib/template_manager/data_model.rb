# Represents the HTML and JS Code
class Sereth::TunnelTemplate::DataModel
  @baseline = <<-js_code
    sereth.render.register("%{path}", function (ctx) {
        ctx.load([%{load}]);
        ctx.gate([%{gate}]);
        ctx.template(%{template});
        ctx.config(%{config})
      });
  js_code
  class << self
    def baseline(path, load: '', gate: '', template: '', config: '')
      @baseline % {path: path, load: load, gate: gate, template: template, config: config}
    end
  end

  attr_reader :metadata
  def initialize(super_node)
    # Core template data
    @metadata = {}
    @load = []
    @gate = []
    @template = nil
    
    # Partial template structure
    @subnodes = []
    @super_node = super_node
  end

  #
  def subnode
    node = self.class.new(self)
    @subnodes.push(node)
    node
  end

  def populate_html(nokogiri_data)
    raise "Invalid Data Type" if !nokogiri_data.is_a?(Nokogiri)
    @html = nokogiri_data
  end

  def populate_control

  end

  def extract

  end

  def parse

  end

  def extract_partials

  end

  def extract_html

  end


end
