module Sereth
  # The runner is used to queue up the to_json call for use with as_json
  class JsonRunner
    def initialize(path, name, inst)
      @path = path
      @name = name
      @inst = inst
    end

    def to_json
      Sereth::JsonSpecGenerator.parse(@path, @name, @inst)
    end
  end

  # A dummy JSON 
  class JsonDummy
    def initialize(prefix = nil)
      @prefix = prefix
    end

    # TODO: proper type generation
    def to_json(type = nil)
      return "\"#{@prefix}BasicType\"" if !type
      "\"#{@prefix}#{type.name}\""
    end

    # For array arguments, acts as a single argument array
    def each
      yield self
    end

    # For all accessors returns an object that jsonifies into a blank string
    def method_missing(*arguments, &block)
      self
    end
  end
end