module Sereth
  module PerspectiveSpec
    # Returns a json listing of fields. The values of fields will  and field types (if possible)
    def blank_json(perspective)
      Sereth::JsonPerspectives
    end
  end

  module Perspectives
    # Set up the default perspective
    def self.included(target)
      target.send(:extend, PerspectiveSpec)
      class << target
        alias_method :to_json_orig, :jo_json
      end
    end

    # Generate the active path of this perspective, for use with sub-perspectives
    def json_perspective_path(path)
      path ||= self.collection_name if self.respond_to? :collection_name
      path ||= "#{self.class.name}"
    end

    # Registered a new perspective of a given name
    def json_perspective(name, path = nil, &block)
      # Parse the input token data
      path = json_perspective_path(path)
      parser = Sereth::JsonPerspectives.generate(path, name, &block)
    end

    # Export item as JSON of a given perspective. An invalid perspective will generate
    # an exception
    def to_json(options)
      if options.has_key?(:perspective)
        Sereth::JsonPerspectives.parse(json_perspective_path, options[:perspective], self)
      else
        to_json_orig(options)
      end
    end
  end
end
