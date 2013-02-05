module Sereth
  module JsonSpecExtender
    # Returns a json listing of fields. The values of fields will  and field types (if possible)
    def blank_json(spec)
      Sereth::JsonSpecs
    end
  end

  module JsonSpecs
    # Set up the default spec
    def self.included(target)
      target.send(:extend, PerspectiveSpec)
      class << target
        alias_method :to_json_orig, :jo_json
      end
    end

    # Generate the active path of this spec, for use with sub-specs
    def json_spec_path(path)
      path ||= self.collection_name if self.respond_to? :collection_name
      path ||= "#{self.class.name}"
    end

    # Registered a new spec of a given name
    def json_spec(name, path = nil, &block)
      # Parse the input token data
      path = json_spec_path(path)
      parser = Sereth::JsonSpecs.generate(path, name, &block)
    end

    # Export item as JSON of a given spec. An invalid spec will generate
    # an exception
    def to_json(options)
      if options.has_key?(:spec)
        Sereth::JsonSpecs.parse(self, options)
      else
        to_json_orig(options)
      end
    end
  end
end
