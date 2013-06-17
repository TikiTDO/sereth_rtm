# Tree logging
#  Multiple perspectives/buffers for threads and others 

# Modify depth for any 
module Sereth
  module DevLogBinding
    def var_in_parent(var_name)
      begin
        i = 0
        while i += 1
          ret = binding.of_caller(i).eval("#{var_name} if defined? #{var_name}")
          return ret if !ret.nil?
        end
      rescue
        return nil
      end
    end

    def dev_sectionize(func, tag)
      # Get the closest parent binding with a 
    end
  end

  module DevLogKernel
    include Callbacks

    def dev_sectionize(func, tag)
      # Get the closest parent binding with a 
      self.define_method :func do |*args, &block|
        Sereth::DevLog.section(tag)
        begin
          super(*args, &block)
        ensure
          Sereth::DevLog.pop
        end
      end
    end
    
    # 
    def putd(*args)
      return if !Sereth::DevLog.active?

      Sereth::DevLog.write(depth, *args)
    end

    def putds(*args)
      if Sereth::DevLog.active?
        putd(*args)
      else
        puts(*args)
      end
    end
  end

  class DevLogBuffers
    # Random name with a low probability of intersection
    @default_buffer = nil
    @buffers = {}

    class << self
      def default_buffer
        @default_buffer ||= LoggerBuffers.new
        @default_buffer
      end

      def get_buffer(id = nil)
        return default_buffer if id.nil?
        @buffers[id] ||= LoggerBuffers.new
        @buffers[id]
      end
    end

    attr_accessor :mirror
    def initialzie(spacer = "  ")
      @io = StringIO.new
      @depth = 0
      @spacer = spacer
      @mirror = nil
    end

    def write(string)
      # Generate the spacer to use for this write
      cur_spacer = ""
      @depth.times{cur_spacer << @spacer}
      # Log the message to the boud IO, and optionally mirror the output elsewhere
      string.split("\n").each do |str|
        to_write = "#{cur_spacer}#{str}"
        @io.write(to_write)
        @mirror.write(to_write) if @mirror
      end
    end

    # Forward everything else to string IO
    def respond_to_missing?(name, include_private = false)
      @io.respond_to?(name, include_private)
    end

    # Forward everything else to string IO
    def method_missing(name, *args, &block)
      @io.send(name, *args, &block)
    end
  end

  class DevLog
    @buffer_table = {}
    @active = false
    class << self
      def active?
        @active
      end

      def activate
        @active = true
      end

      def root

      end
    end

    def initialize(section, depth = 0, buffer = nil)
      @buffer = buffer
      @section = section
      @depth = depth
    end

    def spawn(section)
      self.class.new(section, @depth += 1, @buffer)
    end

  end
end

class Binding
  include Sereth::DevLogBinding
end

module Kernel
  include Sereth::DevLogKernel
end