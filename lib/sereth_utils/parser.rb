=begin
TODO - When adding a regex to lexxer, insert it into the global state 
machine. This state machine can match multiple objects based on context.

Result is based on selection priority
=end

module Sereth

  class Parser
    class << self
      def inherited
        # Log Stuff
      end


    end

    def initialize(raw)
      @raw = raw
      @raw_pos = 0
    end

    def add_query
      next_matcher = nil
      to_match = /\G#{next_matcher}/
    end

    def query
      res = @raw.match(next_query, @raw_pos)
      raise 'Parse Error' if !res
      match = res[0]
      @raw_pos += match.size
      match
    end
  end

  class JSONParser < Parser
    _config do
      ignore_whitespace true
    end
    

    # Global Value
    value! _any(number, string, array, object, literals)

    # Basic value types
    literals! %w{false null true}

    number! do
      opt '-'
      raw(:integers, %r{^(0|[1-9]\d+)})
      opt raw(:frac, '.', /\d+/)
      opt raw(:exp, /e|E/, /\d+/)
      handle 
    end

    string! '"', string_value, '"' do
      string_value! _until(%r{(.*[^\\](\\\\)*|(\\\\)*)?(?=")})
    end

    # Recursive Definitions
    values! _opt(value, _opt(',', values))
    members! _opt(string, ':', value, _opt(',', members))

    # Containers
    array! '[', values, ']'
    object! '{', members, '}'
  end
end