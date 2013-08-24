require 'rkelly'

# Externally Visible Functions
require_relative 'template_manager/api'

# Data Classes
require_relative 'template_manager/manifest'
require_relative 'template_manager/template'

# Operational Interface Shiv
require_relative 'template_manager/rkelly_wrapper'

# Operational Code
require_relative 'template_manager/parser'
require_relative 'template_manager/parser_plugin'
require_relative 'template_manager/core_parser_plugin'

require_relative 'template_manager/generator'
a = <<thing
  (function (){
    code;
  }).call(this);
thing
require 'pry'

parsed = RKelly::Parser.new.parse(a)
binding.pry

# Expression Satament :value ->
#   Function Call :value ->
#     Thing that's being called
#   Function Call :arguments
#     Container for funciton being called