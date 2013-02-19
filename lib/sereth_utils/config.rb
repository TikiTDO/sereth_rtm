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
Command line aguments must specify the argument name, and may also specify any of the preceding
path. The system will to its best to find an argument that matches that name on a first-come
first-serve basis.

 Given:
  config.add_arg('/path/1', :name)
  config.add_arg('/path/2', :name)
 ruby script.rb -name=on #=> [/path/1/name => on, /path/2/name => nil]
 ruby script.rb -1_name=on #=> [/path/1/name => on, /path/2/name => nil]
 ruby script.rb -2_name=on #=> [/path/1/name => nil, /path/2/name => on]
 ruby script.rb -path_2_name=on #=> [/path/1/name => nil, /path/2/name => on]

TODO: Fully formed Flow path

## Usage
class Data
  extend Sereth::Config

  config.add_
end

=end
  
end
module Sereth
  class ConfigDB
  end

  module Config
  end
end