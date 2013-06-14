module Sereth
  module SymbolCallbackIncludes
    # Generate a proc object to be evaluated in a context
    def caller
      return proc {|*input| self.send(*(input + args))}
    end

    # Generate a proc object to be evaluated in a context with arg appended
    def caller_push(*args)
      return proc {|*input| self.send(*(input + args))}
    end

    # Generate a proc object to be evaluated in a context with arg prepended
    def caller_shift(*args)
      return proc do |*input|
        return proc {|*input| self.send(*(args + input))}
      end
    end
  end

  class SymbolCallback
  end
end

class Symbol
  include Sereth::SymbolCallbackIncludes
end