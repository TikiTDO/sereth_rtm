=begin
# Configuration Module
The configuration module allows tools to register configuraiton parameters, and then query 
them as necessay. It also acts as a config file generator, loader, and validator, as well as
an argument parser.

## Parameter Sources
Parameters are sourced from (in order of importance):

1. In-code Configuration
2. Command Line Configuration
3. File Configuration
4. Default Configuration

## Storage
All configuration options are stored at a fully formed path "/path/is/here" with a proper
symbol :name. 

## Command line configuration
Command line aguments must specify the argument name, and may also specify any of the 
preceding path. The system will to its best to find an argument that matches that name,
but will fail if a single match can not be determined

 Given:
  config.add_arg('/path/1', :name)
  config.add_arg('/path/2', :name)

 ruby script.rb -name=on #=> [/path/1/name => on, /path/2/name => nil]
 ruby script.rb -1_name=on #=> [/path/1/name => on, /path/2/name => nil]
 ruby script.rb -2_name=on #=> [/path/1/name => nil, /path/2/name => on]
 ruby script.rb -path_2_name=on #=> [/path/1/name => nil, /path/2/name => on]

TODO: Fully formed Flow path

## Usage
The configuration module is best combined with binding stages in order to ensure that
the execution has proper access to the local context, and all values defined therein.

class Data
  binding.stage :after_data do
    extend Sereth::Config

    args_config :full, "path", :here do
      param :name, "desc", (Integer | String | Boolean) # Specify a data parameter
      exec :name, "desc" &block # Specify a block to execute on parameter
    end
  end
end

=end
module Sereth
  class ConfigDB
    # Register the config paramters
    binding.stage :sereth_util_loaded do
      extend Config
    end

    @full_names = {}
    @data = {}

    class << self
      def parse_file

      end

      def parse_args

      end

      def gen_path(path)

      end

      def get_path(path)
        path = path.split('/').map(&:to_sym)
        @data.get(*path)

      end

      def parse

      end
    end

    def initialize

    end

    def add(name, type)

    end

    def set(name, value)

    end
  end

  module Config
    # This module is only for extension
    def self.included(target)
      raise "The #{self} Module should only be extended, not included."
    end

    # Add the callback method added to the method_added stack
    def self.extended(target)    
      # Stack the method_added callback
      raise "Cannot exted system_config" if target.method_defined?(:system_config)
    end

    def args_config(*path,  &block)
      path = path.map(&:to_sym)
      ConfigDB
    end
  end
end