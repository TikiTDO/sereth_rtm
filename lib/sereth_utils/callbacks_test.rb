require_relative 'all'
class Test
  extend Sereth::Callbacks


  before_method :test do

    @result.push('b')
  end
  before_method :test do
    @result.push('b1')
  end
  after_method :test do
    @result.push('a')
  end
  after_method :test do
    @result.push('a1')
  end
  around_method :test do |runner|
    @result.push('arb')
    runner.call
    @result.push('arf')
  end

  def test
    @result.push('hi')
  end

  def initialize
    @result = []
  end

  def report
    want = "arb--b1--b--hi--a--a1--arf"
    have = @result.join('--')
    puts "Have: #{have}"
    puts "Want: #{want}"
    if have == want then puts "Pass" else puts "FAIL" end
  end
end

t = Test.new
t.test
t.report

