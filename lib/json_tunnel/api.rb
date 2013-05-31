module Sereth::JsonTunnel
  # System meant to operate on prepends
  def self.included(target)
    raise "JsonTunnel must be prepended."
  end

  # Set up the default spec
  def self.prepended(target)
    target.send(:extend, ClassAPI)
    target.send(:prepend, InstAPI)
  end

  # Helper to generate a tunneled error
  def self.error(message, type = nil)
  end

  module ClassAPI
    # Generate the active path of this spec, for use with sub-specs
    def json_spec_path
      path = self.collection_name if self.respond_to? :collection_name
      path ||= "#{self.name}"
      return path
    end

    # Returns a json listing of fields. The values of fields will and field types (if possible)
    def json_spec_schema(spec)
      Data.export(json_spec_path, spec, DummyUtil.new)
    end

    # Iterate over all the specs defined in the current class
    def each_json_spec(&block)
      Data.each(json_spec_path, &block)
    end

    # Registered a new spec of a given name
    def json_spec(name, &block)
      # Parse the input token data
      Data.generate(json_spec_path, name, &block)
    end
  end

  module InstAPI
    # Helper for properly rendering a specced instance, or collection of instances
    def to_json_from(data, *args)
      if data.responds_to? :each and not data.responds_to? :to_json_from
        # Ensure we don't render tunnelled data that also happens to define each
        ret = '{'
        ph = ''
        # Render a collection, unless collection is a speced item
        data.each do |inst| 
          ret << inst.to_json(*args) << ph
          ph = ',' if ph == ''
        end
        ret << '}'
        return ret
      else
        # Render any properly specced item
        return inst.to_json(*args)
      end
    end

    # Export item as JSON of a given spec. An invalid spec will generate
    # an exception. Will optionally extra-escape data for inclusion in initial template.
    def to_json(_ = {}, spec: nil, escape: false, wrapper: false)
      if spec
        # Get a string containing the JSON data
        ret = Data.export(self.class.json_spec_path, spec, self)

        # Wrap the resulting JSON for message passing
        if wrapper && wrapper.responds_to?(:wrap)
          ret = wrapper.wrap(ret)
        end

        # Escape key characters when rendering directly into javascript
        if escape
          ret = ret.to_json
          ret = ret.html_safe if ret.responds_to?(:html_safe)
        end
        return ret
      elsif defined?(super)
        super
      end
    end

    # Wraps the proper to_json call for use with rails render method
    def as_json(options = {})
      if options[:spec]
        RunnerUtil.new(self, options)
      else
        super
      end
    end

    # Perform the import operation
    def from_json(data, _ = {} , spec: nil)
      data = JSON.parse(data) if data.is_a?(String)
      if spec
        Data.import(self.class.json_spec_path, spec, self, data)
      elsif defined?(super)
        super
      end
    end
  end  
end