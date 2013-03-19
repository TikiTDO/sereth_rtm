# Initialize the testing environment
def require_lib(path)
  Sereth::Tester.require_project(path)
end 

def time_point(name)
  Sereth::Tester.time_point(name)
end

def time_report
  Sereth::Tester.time_report
end

module Sereth
  class Tester
    @root = `git rev-parse --show-toplevel`.strip
    @time_log = {}
    class << self
      def require_project(path)
        require_relative "#{@root}/lib/#{path}"
      end

      def time_point(name)
        @time_log ||= {}
        @time_log[name] = [] if !@time_log.has_key? name
        @time_log[name] << Time.now
      end

      def time_report
        return if !defined? @time_log
        report_time = Time.now
        report = "Since %-30s: %f seconds"
        puts "****** Time Report ******"
        @time_log.each do|name, vals|
          if vals.size == 1
            puts report % [name, report_time - vals.first]
          else
            vals.each_index {|i| puts report % ["#{name}[#{i}]", report_time - vals[i]]}
          end
        end
      end
    end
  end
end


