# Stub class for the JSON spec cache API. Can be extended to provide actual cache functionality
module Sereth
  # TODO Override this cache with other types
  class JsonSpecCache
    @cache = {}
    class << self
      # Configure the cache provider
      def provide(provider)
        @provider = provider
      end

      # True if the cache is enabled
      def enabled?
        return @provider.enabled? if !@provier.nil?
        true
      end

      # Either retrieves teh cached data, or a nil in the event of expiry/non-caching
      def retrieve(*args)
        return @provider.retrieve(*args) if !@provider.nil?
        @cache[args]
      end

      # Store the generated value in the hash
      def store(value, *args)
        return @provider.store(value, *args) if !@provider.nil?
        @cache[args] = value
      end
    end
  end
end
