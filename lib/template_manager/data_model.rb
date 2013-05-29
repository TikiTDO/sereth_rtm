# Represents the HTML and JS Code
class Sereth::TunnelTemplate::DataModel
  def initialize(raw)
    @raw = raw
    raw_parsed = Nokogiri::HTML.fragment(raw)
    @partials = {}
    @raw_scripts = raw_parsed.xpath('*//script[@type="text/javascript"]').remove
    @raw_ejs = raw_parsed.to
  end

  def parse

  end

  def extract_partials

  end

  def extract_html

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
