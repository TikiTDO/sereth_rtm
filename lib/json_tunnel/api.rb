module Sereth::JsonTunnel
  module ClassMethods
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
  # System meant to operate on prepends
  def self.included(target)
    raise "JsonTunnel must be prepended."
  end

  # Set up the default spec
  def self.prepended(target)
    target.send(:extend, ClassMethods)
  end

  # Helper to generate a tunneled error
  def self.error(message, type = nil)
  end

  # Export item as JSON of a given spec. An invalid spec will generate
  # an exception. Will optionally extra-escape data for inclusion in initial template.
  def to_json(_ = {}, spec: nil, escape: false)
    if spec
      ret = Data.export(self.class.json_spec_path, spec, self)
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
    if options.has_key?(:spec)
      RunnerUtil.new(self.class.json_spec_path, options[:spec], self)
    else
      super
    end
  end

  # Perform the import operation
  def from_json(data, options)
    data = JSON.parse(data) if data.is_a?(String)
    if options.has_key?(:spec)
      Data.import(self.class.json_spec_path, options[:spec], self, data)
    elsif defined?(super)
      super
    end
  end
end