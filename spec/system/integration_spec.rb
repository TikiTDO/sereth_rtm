require 'spec_helper'

describe 'json_spec operaion' do
  before :each do
    @target_class = Class.new do
      def num; 1; end
      def str; 'test'; end
      def arr; [1, 2]; end
      def err; raise 'test error'; end
      def subinst; self.class.new; end
      def args(*args); args; end

      prepend Sereth::JsonSpec
    end
    @target = @target_class.new
  end

  context 'single' do
    it 'basic node' do
      @target_class.json_spec :basic_node do
        num
      end
      @target.to_json(spec: :basic_node).should == '{"num": 1}'
    end

    it 'symbol basic node' do
      @target_class.json_spec :symbol_node do
        foo :num
      end
      @target.to_json(spec: :symbol_node).should == '{"foo": 1}'
    end

    it 'dynamic basic node' do
      @target_class.json_spec :dynamic_node do
        foo get: proc {num}
      end
      @target.to_json(spec: :dynamic_node).should == '{"foo": 1}'
    end

    it 'default value' do
      @target_class.json_spec :default_node do
        num get: proc {2}
      end
      @target.to_json(spec: :default_node).should == '{"num": 2}'
    end

    it 'fails on invalid query' do
      @target_class.json_spec :default_node do
        num get: proc {2}
      end
      expect{}
    end
  end

  context 'collection' do
    it 'Put data in array' do
      @target_class.json_spec :basic_node do
        num Array
      end
      @target.to_json(spec: :basic_node).should == '{"num": [1]}'
    end
  end

end