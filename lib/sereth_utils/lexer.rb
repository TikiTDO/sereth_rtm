module Sereth

  class Lexer
    class << self
      def inherited
        # Log Stuff
      end
    end
  end

  class JSONLexer < Lexer
    _ignore_whitespace

    # Global Value
    value! _any(number, string, array, object, literals)

    # Basic value types
    literals! %w{false null true}

    number! _opt('-'), integers, _opt(frac), _opt(exp) do
      integers! %r{^(0|[1-9]\d+)}
      frac! '.', /\d+/
      exp!(/e|E/, /\d+/)
    end

    string! '"', string_value, '"' do
      string_value! _until(%r{^(.*[^\\](\\\\)*|(\\\\)*)?(?=")})
    end

    # Recursive Definitions
    values! _opt(value, _opt(',', values))
    members! _opt(string, ':', value, _opt(',', members))

    # Containers
    array! '[', values, ']'
    object! '{', members, '}'
  end
end