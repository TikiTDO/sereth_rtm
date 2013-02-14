module Sereth
  # TODO Override this cache with other types
  class JsonSpecCache
    @store = {}
    def self.save(*args)
      data = args.pop
      @store[args] = data
    end

    def get_cached(*args)
      return @store[args]
    end
  end
end
