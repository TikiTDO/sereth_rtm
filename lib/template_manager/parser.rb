# Provides JS parsing and generation interface
class Sereth::TemplateManager::Parser
  @parser = RKelly::Parser.new
  @baseline = <<-js_code
    sereth.render.inject("render_path", function (ctx) {
        ctx.load([]);
        ctx.gate([]);
        ctx.template(function (args) {});
        ctx.config({'key' => 'val'})
      });
  js_code

  class << self
    addr_readable :parser
    def extract_baseline
      baseline = @parser.parse(@baseline)
      @render_path = baseline.pointcut('"baseline"')
      
      # The load callbacks fire when the context is instantiated
      @load_js = baseline.pointcut('ctx.load([])').arguments.value.first
      # The gate callbacks fires around the template handler
      @gate_js = baseline.pointcut('ctx.gate([])').arguments.value.first
      # The template handler receives parsed EJS output, and injects it int he function
      @template_js = baseline.pointcut('ctx.template(function (args) {})').arguments.value.first
    end
  end

  def self.parse(raw)
    @parser.parse(raw)
  end


  def initialize(raw, path)
    data = Parser.new(raw, )
    @raw = raw
    raw_parsed = Nokogiri::HTML.fragment(raw)
    @partials = {}
    @raw_scripts = raw_parsed.xpath('*//script[@type="text/javascript"]').remove
    @raw_ejs = raw_parsed.to

    # Source data for generating the result
    @parsed = self.class.parse(raw)
    
    # AST for resulting code, to be returned as JS
    @result = self.class.parse(self.class.baseline)

    # Extract the node for the load handler array
    @on_load = @result.pointcut('ctx.load([])').arguments.value.first 
    # Extract the node for the gate handler array
    @around_show = @result.pointcut('ctx.gate([])').arguments.value.first
    # Extract the node for the template handler
    @shower = @result.pointcut('ctx.shower(function () {})').arguments.value.first
  end

  # Extract any metadata encoded in the template for inclusion in the manifest
  def metadata 

  end

  # Extract a top-level context handler from the parsed, and add it to a result queue
  def extract_handler(name, queue)

  end

  # Inject javascript code to be run in order to generate the template.
  def inject_template(template)

  end

  def extract_js
    # Parse the core scripts
    script_parser = RKelly::Parser.new
    parsed_scre
    @raw_scripts.children.each {|cdata|
      script_parser.parse(cdata.content)
    }
    
    @pased_scripts = script_parser(@raw_scripts)

    shiv = <<-here
      sereth.template("rename") {
        this.around = [function () {}]
        this.render = [function () {}]
      }
    here
    
    @shiv = script_parser.parse(shiv)

    @name = @shiv.pointcut('"rename"')
    # Get the array elements containing the callbacks
    @around_callbacks = @shiv.pointcut('around = [function () {}').matches.first.value
    @render_callbacks = @shiv.pointcut('render = [function () {}').matches.first.value

    # Adding to callbacks

    b = res.pointcut('a = [function() {} ]').matches.first.value.dup
    code_nodes = p.parse("return 1+1")

    body = RKelly::Nodes::FunctionBodyNode.new(code_nodes)
    expr = RKelly::Nodes::FunctionExprNode.new('function', body)
    elem = RKelly::Nodes::ElementNode.new(expr)
    b.value.push(elem)
    
    @around_callbacks.value.push(elem)

    # Pointcut = fancy search
  end
end