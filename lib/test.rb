def time_point(name)
  $time_points ||= {}
  $time_points[name] = [] if !$time_points.has_key? name
  $time_points[name] << Time.now
end

def time_report
  return if !defined? $time_points
  report_time = Time.now
  report = "Since %-30s: %f seconds"
  puts "****** Time Report ******"
  $time_points.each do|name, vals|
    if vals.size == 1
      puts report % [name, report_time - vals.first]
    else
      vals.each_index {|i| puts report % ["#{name}[#{i}]", report_time - vals[i]]}
    end
  end
end

time_point("Start")
require 'rubygems'
require 'pry'
require 'ap'
require 'ruby-prof'
require_relative 'json_spec'

time_point("After Require")

class Object
  def to_json
    return "null" if self.nil?
    "#{self.inspect}"
  end
end


class Foo
  include Sereth::JsonSpec

  def id
    1
  end
end

class Test
  include Sereth::JsonSpec

  def foo
    @foo ||= Foo.new
    @foo
  end

  def hello
    "aa"
  end

  def arr
    [1, 2]
  end

  def str
    "string"
  end

  def num
    1
  end

  def mis_str
    nil
  end

  json_spec :ext do
    id
  end

  json_spec :hi do
    hello
    bye proc {hello}
    str String
    num Integer
    mis_str String

    arr Array
    rarr Array, proc {arr}

    foo do
      id
    end

    bar Array, :foo do
      id
    end

    zzz :foo do
      extends! :ext
    end

    override! :else, :hello
    if! proc {false} do puts 'should not happen' end
    if! proc {true} do next; puts 'should happen' end
  end
end

time_point("After Specs")

# Test Execution
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-b", "--benchmark", "Run Benchmark") do |v|
    options[:benchmark] = v
  end
  opts.on("-t", "--time", "Time report") do |v|
    options[:time] = v
  end
  opts.on("-l", "--blank", "Generate blank spec") do |v|
    options[:blank] = v
  end
  opts.on("-g", "--gen", "Save the output to be used for comparison later.") do |v|
    options[:gen] = v
  end
end.parse!

time_point("After Opt")

test = Test.new
# Benchmark
if options[:benchmark]
  require 'benchmark'
  Benchmark.bm do |b|
    b.report('') do
      10000.times {
        test.to_json(:spec => :hi)
      }
    end
  end
elsif options[:time]
  start = Time.now
  10000.times {test.to_json(:spec => :hi)}
  puts "Time: #{Time.now - start}"
elsif options[:blank]
  result_file = 'blank.result'
  result = Test.json_spec_schema(:hi)
else
  result_file = 'normal.result'
  result = test.as_json(:spec => :hi).to_json
end

if result
  puts "Result: #{result}"
  if options[:gen]
    File.open(result_file, 'w') do |file|
      file.write result
    end
  elsif File.exists?(result_file)
    if File.readlines(result_file).first == result
      puts "Valid Match!"
    else
      puts "!!!! INVALID MATCH !!!!"
    end
  else

  end
end
time_report