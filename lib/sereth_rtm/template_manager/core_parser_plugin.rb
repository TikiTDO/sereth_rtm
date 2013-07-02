# Implements the core operations for the parser
class Sereth::TemplateManager
  class CoreParserPlugin < ParserPlugin
    ## Parsing Instructions
    # Navigates down the preamble, and entres active parsing mode
    on_parse do
      down_preamble if is_preamble?
      state :active
    end

    # Goes through each expression in the active mode
    on_state :active do
      true while next_node
    end

    # Check for core entities when a new node is entered in the active state
    on_entry in_state: :active do
      # Only care about function calls
      next if !is_call?

      # Check if we hit a know call type
      case call_name
      when 'load'
        store_call_body('load')
      when 'inst'
        replace_yield
        store_call('inst')
      when 'clean'
        store_call('clean')
      when 'config'

      end
    end

    ## AST navication function
    # A premable often wraps ruby code in a function
    # Example:
    #  (function (){}).call(this);
    def is_preamble?
    end

    # Go through a preamble into a new node
    def down_preamble

    end

    # A CallExpresion http://www.ecma-international.org/ecma-262/5.1/#sec-11.2
    def is_call?
    end

    # Get the name of the function being called
    def call_name
      function_node
    end

    # An assign is any expression that sets a named value
    # Example:
    #  thing = ...;
    def is_assign?
    end

    def assign_name
    end

    # An operation is 
    def is_operation?
    end

    def is_dot_access?
    end

    def get_caller(item)
    end

    def get_callee(item)
    end

    def get_function_body(item)
    end

    ## Template Generation Functions
    def add_load(item)
      # Store some data in inst variables
    end

    def add_gate(item)
    end

    def add_template(item)
    end

    def add_config(item)
    end

    def generate
      # Get inst variables
      # Append some stuff to the @result
    end
  end
end
