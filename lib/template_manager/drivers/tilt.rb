module Sereth
  class TunnelTemplate < Tilt::Template
    # Dependencies
    autoload :Nokogiri, 'nokogiri'

    # Library Classes
    autoload :DataModel, 'template_manager/data_model'
    autoload :TemplateGenerator, 'template_manager/template_generator'

    # Combine Slim + Coffee/Javascript
    self.default_mime_type = 'application/javascript'

    def prepare
      @model = DataModel.new(self.data)
    end

    def evaluate(scope, locals, &block)
      #@model.extract_ejs

      #html = data_to_html(self.data)
      #js = parse_js(html.extract_js!)
      'Woo!'
    end
  end
end
