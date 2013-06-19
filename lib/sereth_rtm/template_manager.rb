# Externally Visible Functions
require_relative 'template_manager/api'

# Data Classes
require_relative 'template_manager/manifest'
require_relative 'template_manager/template'

# Operational Code
require_relative 'template_manager/parser'
require_relative 'template_manager/parser_plugin'
require_relative 'template_manager/core_parser_plugin'

require_relative 'template_manager/generator'