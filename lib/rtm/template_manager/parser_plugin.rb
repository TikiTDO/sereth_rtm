# Parser plugins allow libraries to plugin to the parsing process and call
# other ruby code. Executed plugins are stored as part of the DataInst metadata
class Sereth::TemplateManager
  class ParserPlugin
  end

  # Core plugins
  class CoreParserOperations < ParserPlugin
    # Load
    # Gate
    # Template
    # Config
  end
end
