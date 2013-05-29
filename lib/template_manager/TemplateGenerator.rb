# Provides JS parsing and generation interface
class Sereth::TunnelTemplate::TemplateGenerator
  @parser = RKelly::Parser.new
  @baseline = <<-js_code
    sereth.render.inject("render_path", function (ctx) {
        ctx.load([]);
        ctx.gate([]);
        ctx.template(function (args) {});
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
    # Source data for generating the result
    @parsed = self.class.parse(raw)
    
    # AST for resulting code, to be returned as JS
    @result = self.class.parse(self.class.baseline)

    @on_load = @result.pointcut('ctx.on_load([])').arguments.value.first
    @around_show = @result.pointcut('ctx.around_show([])').arguments.value.first
    @shower = @result.pointcut('ctx.shower(function () {})').arguments.value.first
  end

  # Extract a top-level context handler from the parsed, and add it to a result queue
  def extract_handler(name, queue)

  end

  # Inject javascript code to be run in order to generate the template.
  def inject_template(template)

  end
end