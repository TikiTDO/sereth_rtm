module Sereth::JsonSpec
  # The runner is used to queue up the to_json call for use with as_json
  class RunnerUtil
    def initialize(path, name, inst)
      @path = path
      @name = name
      @inst = inst
    end

    def to_json(*_)
      Data.export(@path, @name, @inst)
    end
  end

  # A dummy object for representing the instance of the item being jsonified.
  class DummyUtil
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

  # Info about the failed export
  class ExportError < StandardError
    def initialize(path, name, child = nil)
      @path = path
      @name = name
      @child = child
    end

    def message
      ret = "Error exporting JSON data for [#{@path}/#{@name}]"
      if @child
        ret << ":\n\t"
        ret << @child.message
      end
    end

    def backtrace
      @child.backtrace
    end
  end
end