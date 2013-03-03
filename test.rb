require_relative 'test_utils'

time_point("Start")
require 'rubygems'
require 'pry'
require 'ap'

require_lib 'json_spec'

time_point("After Require")

## Example Data
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

  json_spec :ext do
    id
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

  def should_happen
    'This should happen'
  end

  def should_not_happen
    'This should NEVER happen'
  end
end

# Testable Section
class Test

  # Basic Specs
  json_spec :basic do
    hello
  end

  json_spec :basic_proc do
    bye proc {hello}
  end

  json_spec :basic_typed_string do
    str String
  end
  json_spec :basic_typed_num do
    num Integer
  end

  json_spec :basic_nil do
    mis_str String
  end

  # Array Specs
  json_spec :arr do
    arr Array
  end

  json_spec :arr_proc do
    rarr Array, proc {arr}
  end

  json_spec :arr_typed do
    typed_arr [Array, Integer], proc {arr}
  end

  # Object Specs
  json_spec :obj do
        foo do
      id
    end
  end

  json_spec :obj_arr do
    bar Array, :foo do
      id
    end
  end

  json_spec :obj_ext do
    zzz :foo do
      extends! :ext
    end
  end

  json_spec :override do
    override! :else, :hello
  end

  json_spec :cond_false do
    if! proc {false} do
     should_not_happen 
    end
  end

  json_spec :cond_true do
    if! proc {true} do
     should_happen 
    end
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
  opts.on("-s", "--schema", "Generate schema") do |v|
    options[:schema] = v
  end
  opts.on("-g", "--gen", "Save the output to be used for comparison later.") do |v|
    options[:gen] = v
  end
  opts.on("-p", "--profile", "Profile the execution.") do |v|
    options[:profile] = v
  end
end.parse!

time_point("After Opt")

test = Test.new
# Benchmark
if options[:benchmark]
  require 'benchmark'
  Benchmark.bm do |b|
    for i in 1..5
      b.report("Round #{i} - 10k Runs") do
        10000.times {test.to_json(:spec => :hi)}
      end
    end
  end
end

# Profile
if options[:profile]
  require 'ruby-prof'
  RubyProf.start
  10000.times {test.to_json(:spec => :hi)}
  report = RubyProf.stop
end

# Stopwatch
if options[:time]
  start = Time.now
  10000.times {test.to_json(:spec => :hi)}
  puts "Time: #{Time.now - start}"
end

# Schema Generation
if options[:schema]
  result_file = 'blank.result'
  result = Test.json_spec_schema(:hi)
else
  result_file = 'normal.result'
  result = ''
  Sereth::JsonSpecGenerator.each(Test) do |k, v|
    result << "#{key}:\n" << test.as_json(:spec => :hi).to_json << "\n"
  end
end

# Reporting
if result
  puts "Result: #{result}"
  if options[:gen]
    File.open(result_file, 'w') do |file|
      file.write result
    end
  elsif File.exists?(result_file)
    valid_result = File.readlines(result_file).first
    if valid_result.strip == result.strip
      puts "Valid Match!"
    else
      puts "!!!! INVALID MATCH !!!!"
      puts "Valid:: #{valid_result}"
    end
  else

  end
end
time_report
