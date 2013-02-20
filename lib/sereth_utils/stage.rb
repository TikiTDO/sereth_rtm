=begin
# Staging Module
Allows for the configuration of execution stages, and provides code to be executed in
that stage. Node, code is executed in the current context. 

This is particularly useful for tasks that need to be performed at specific spots in 
the loading process. May also be useful for cleanup code.

## Usage
binding.stage :name do
  ... code ...
end

# Example
$result = []
class Ex
  val = 1
  $result.push(val)
  binding.stage(:after) {$result.push(val)}
  val = 2
end

Sereth::Stage.run_stage :after 

$result == [1, 2]
=end
require 'sourcify'

class Binding
  def stage(name, &block)
    Sereth::Stage.add_stage(name, self, block)
  end

  def exec(&block)
    return if block.nil?
    self.eval(block.to_source(:strip_enclosure => true))
  end
end

module Sereth
  class Stage
    @db = {}
    class << self
      def add_stage(name, target_binding, code)
        @db[name] ||= Stage.new(name)
        @db[name].add(target_binding, code)
      end

      def run_stage(name)
        @db.delete(name).run
      end
    end

    def initialize(name)
      @name = name
      @targets = []
    end

    def add(target_binding, code)
      @targets.push([target_binding, code])
    end

    def run
      @targets.each {|target_binding, code| target_binding.exec(&code)}
    end
  end
end

$result = []
class Ex
  val = 1
  $result.push(val)
  binding.stage(:after) {$result.push(val)}
  val = 2
end

Sereth::Stage.run_stage :after 

puts $result.to_s
puts $result == [1, 2]