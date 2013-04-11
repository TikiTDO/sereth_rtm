require 'spec_helper'

describe 'json_spec operaion' do
  before :each do
    @target_class = Class.new do
      def initialize(parent = nil); @parent = parent; end
      def num; 1; end
      def str; 'test'; end
      def arr; [1, 2]; end
      def err; raise 'test error'; end
      def t; true; end
      def f; false; end
      def subinst; self.class.new(self); end
      def set_data(*args) @parent ? @parent.set_data(*args) : @data = args; end
      def data; @data; end

      prepend Sereth::JsonTunnel
    end
    @target = @target_class.new
  end

  it 'fails when spec not defined' do
    expect{@target.to_json(spec: :undefined)}.to raise_exception
  end

  it 'empty json on empty spec' do
    @target_class.json_spec :empty do; end
    @target.to_json(spec: :empty).should == "{}"
  end

  context 'single' do
    it 'basic node' do
      @target_class.json_spec :basic_node do
        num
      end
      @target.to_json(spec: :basic_node).should == '{"num":1}'
    end

    it 'symbol basic node' do
      @target_class.json_spec :symbol_node do
        foo :num
      end
      @target.to_json(spec: :symbol_node).should == '{"foo":1}'
    end

    it 'dynamic basic node' do
      @target_class.json_spec :dynamic_node do
        foo get: proc {num}
      end
      @target.to_json(spec: :dynamic_node).should == '{"foo":1}'
    end

    it 'default value' do
      @target_class.json_spec :default_node do
        num get: proc {2}
      end
      @target.to_json(spec: :default_node).should == '{"num":2}'
    end

    it 'working on type success' do
      @target_class.json_spec :basic_typed do
        num type: Integer
      end
      expect{@target.to_json(spec: :basic_typed)}.not_to raise_exception
    end

    it 'exception on type error' do
      @target_class.json_spec :basic_typed do
        str type: Integer
      end
      expect{@target.to_json(spec: :basic_typed)}.to raise_exception
    end
  end

  context 'collection' do
    it 'put basic data in array' do
      @target_class.json_spec :basic_arr do
        num Array
      end
      @target.to_json(spec: :basic_arr).should == '{"num":[1]}'
    end

    it 'query array data' do
      @target_class.json_spec :arr do
        arr Array
      end
      @target.to_json(spec: :arr).should == '{"arr":[1,2]}'
    end

    it 'symbol array' do
      @target_class.json_spec :symbol_arr do
        foo Array, get: :arr
      end
      @target.to_json(spec: :symbol_arr).should == '{"foo":[1,2]}'
    end

    it 'dynamic array' do
      @target_class.json_spec :dynamic_arr do
        foo Array, get: proc{arr}
      end
      @target.to_json(spec: :dynamic_arr).should == '{"foo":[1,2]}'
    end

    it 'dynamic array single return' do
      @target_class.json_spec :dynamic_arr_sr do
        foo Array, get: proc{num}
      end
      @target.to_json(spec: :dynamic_arr_sr).should == '{"foo":[1]}'
    end

    it 'typed array passes on valid types' do
      @target_class.json_spec :dynamic_arr do
        arr Array, type: Integer
      end
      @target.to_json(spec: :dynamic_arr).should == '{"arr":[1,2]}'
    end

    it 'typed array fails on invalid types' do
      @target_class.json_spec :dynamic_arr do
        arr Array, type: String
      end
      expect{@target.to_json(spec: :dynamic_arr)}.to raise_exception
    end
  end

  context 'object' do
    it 'basic object node' do
      @target_class.json_spec :obj do
        subinst do
          num
        end
      end
      @target.to_json(spec: :obj).should == '{"subinst":{"num":1}}'
    end
      
    it 'glue object node' do
      @target_class.json_spec :glue do
        cur get: proc {self} do
          num
        end
      end
      @target.to_json(spec: :glue).should == '{"cur":{"num":1}}'
    end

    it 'object extension' do
      @target_class.json_spec :ext_src do
        num get: proc{5}
      end
      @target_class.json_spec :ext do
        subinst do
          extends! :ext_src
        end
      end

      @target.to_json(spec: :ext).should == '{"subinst":{"num":5}}'
    end

    it 'full path object extension' do
      @target_class.json_spec :extf_src do
        num get: proc{5}
      end
      @target_class.json_spec :extf do
        subinst do
          extends! @target_class, :extf_src
        end
      end

      @target.to_json(spec: :extf).should == '{"subinst":{"num":5}}'
    end

    it 'object extension override' do
      @target_class.json_spec :exto_src do
        num get: proc{5}
      end
      @target_class.json_spec :exto do
        subinst do
          extends! :exto_src
          num
        end
      end

      @target.to_json(spec: :exto).should == '{"subinst":{"num":1}}'
    end
  end

  context 'conditional' do
    it 'true conditional symbol source' do
      @target_class.json_spec :cond_sym_t do
        if! :t do
          num
        end
      end

      @target.to_json(spec: :cond_sym_t).should == '{"num":1}'
    end

    it 'false conditional symbol source' do
      @target_class.json_spec :cond_sym_f do
        if! :f do
          num
        end
      end

      @target.to_json(spec: :cond_sym_f).should == '{}'
    end

    it 'true conditional proc source' do
      @target_class.json_spec :cond_proc_t do
        if! proc {t} do
          num
        end
      end

      @target.to_json(spec: :cond_proc_t).should == '{"num":1}'
    end

    it 'true conditional proc source' do
      @target_class.json_spec :cond_proc_f do
        if! proc {f} do
          num
        end
      end

      @target.to_json(spec: :cond_proc_f).should == '{}'
    end
  end

  context 'error handing' do
    it 'key does not exist' do
      @target_class.json_spec :err_dne do
        dne
      end

      expect{@target.to_json(spec: :err_dne)}.to raise_error(Sereth::JsonTunnel::ExportError)
    end

    it 'key triggers error' do
      @target_class.json_spec :err_dne do
        err
      end

      expect{@target.to_json(spec: :err_dne)}.to raise_error(Sereth::JsonTunnel::ExportError)
    end
  end


  context 'imports' do
    it 'basic imports' do
      @target_class.json_spec :import do
        data set: :set_data
      end

      @target.from_json('{"data": 1}', spec: :import)
      @target.data.should == [1]
    end

    it 'sub object import' do
      @target_class.json_spec :sub_import do
        subinst do
          data set: :set_data
        end
      end

      @target.from_json('{"subinst": {"data": 2}}', spec: :sub_import)
      @target.data.should == [2]
    end
  end

end