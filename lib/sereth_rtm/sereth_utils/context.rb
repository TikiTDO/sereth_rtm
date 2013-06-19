# Half assed context replacement
class Sereth::Context
  class << self
    def top
      @top ||= Context.new
    end

    def current
      ctx = Thread.current[:context]
      if !ctx
        ctx = top.generate
        Thread.current[:context] = ctx
      end
      return ctx if ctx
    end
  end


end