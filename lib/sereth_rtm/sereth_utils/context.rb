# Half assed context replacement
class Sereth::Context
  class << self
    # The top context stores system level details, and exports config to children
    def top
      @top ||= Context.new
    end

    # Start a new context from the top
    def wipe
      top.generate
    end

    def current
      ctx = Thread.current[:context]
      ctx = top.generate if !ctx
      return ctx
    end

    # Shorthand alias to query current context instance get
    alias_method :[], :get
    def get(key)
      current.get(key)
    end

    # Shorthand alias to query current context instance set
    alias_method :[]=, :set
    def set(key, value)
      current.set(key, value)
    end
  end

  # Create a new context from the current one
  def generate
    Thread.current[:context] = Context.new(self)
  end

  # Create a new context. Parents not exposed
  def initialize(parent = nil)
    @parent = parent
    @data = {}
  end

  # Storage retreival
  alias_method :[], :get
  def get(key)
    # Query parents if value not found
    if !(res = @data[key]).nil?
      return res
    elsif !parent.nil? 
      return parent.get(key)
    end
    # Defaults to nil if value not found
    return nil
  end

  # Storage assignment
  alias_method :[]=, :set
  def set(key, value)
    @data[key] = value
  end
end