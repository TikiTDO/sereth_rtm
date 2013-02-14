module Sereth
  module JsonSpecExtender
    # Generate the active path of this spec, for use with sub-specs
    def json_spec_path(path)
      path ||= self.collection_name if self.respond_to? :collection_name
      path ||= "#{self.name}"
    end

    # Returns a json listing of fields. The values of fields will  and field types (if possible)
    def json_spec_schema(spec)
      Sereth::JsonSpecGenerator.parse(self.name, spec, JsonDummy.new)
    end

    # Registered a new spec of a given name
    def json_spec(name, path = nil, &block)
      # Parse the input token data
      path = json_spec_path(path)
      Sereth::JsonSpecGenerator.generate(path, name, &block)
    end
  end

  module JsonSpec
    # Set up the default spec
    def self.included(target)
      target.send(:extend, JsonSpecExtender)
      target.send(:alias_method, :to_json_orig, :to_json)
      target.send(:alias_method, :as_json_orig, :as_json)
    end

    # Export item as JSON of a given spec. An invalid spec will generate
    # an exception
    def to_json(options)
      if options.has_key?(:spec)
        Sereth::JsonSpecGenerator.parse(self.class.name, options[:spec], self)
      else
        to_json_orig(options)
      end
    end

    # Wraps the proper to_json call for use with rails render method
    def as_json(options)
      if options.has_key?(:spec)
        JsonRunner.new(self.class.name, options[:spec], self)
      else
        as_json_orig(options)
      end
    end
  end
end
