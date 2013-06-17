module Sereth::JsonTunnel
  class Imports
    class << self
      # Create a proc to execute the update operation given a update handler (setter)
      def basic!(setter)
        return proc do |inst, val|
          # Ensure the basic value is a literal before setting
          val = val.to_s unless val.is_a?(String) || val.is_a?(Numeric) || val.nil?
          # Run the setter for the basic value
          inst.instance_exec(inst, val, &setter)
        end
      end

      # Create a proc to handle updates to subnodes
      def subnode!(subnode, getter)
        return proc do |inst, val|
          new_inst = inst.instance_eval(&getter)
          subnode.import!(new_inst, val)
        end
      end
    end
  end
end