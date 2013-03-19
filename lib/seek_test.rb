string = "a" * 10_000
string_v = "a" * 10_000 + "b"

require 'benchmark'
puts Benchmark.measure{string.match(/a.*?b/)}
puts Benchmark.measure{string.match(/a[^b]*b/)}
puts Benchmark.measure{string_v.match(/a[^b]*b/)}
puts Benchmark.measure{string.match(/a.*/)}

data = {:state => :start}
matcher = Object.new
matcher_class = class << matcher; self; end
match = ""

matcher_class.send(:define_method, :start) do |c|
  # Start state runs only once, so it's the last one
  next if c != 'a'
  match << c
  data[:state] = :not_b
  next
end


matcher_class.send(:define_method, :not_b) do |c|
  match << c
  next if c != 'b'
  break
end
puts Benchmark.measure {
  string.each_char {|c|
    state = data[:state]
    matcher.send(state, c)
  }
}
