require 'spec_helper'

describe :api do
  before :each do
    @target_class = Class.new
    @target_class.send(:define_method, :to_json) {|*options| :default}
  end

  it 'include in class fails' do
    expect {@target_class.send(:include, Sereth::JsonSpec)}.to raise_error
  end

  it 'prepend in class works' do
    expect {@target_class.send(:prepend, Sereth::JsonSpec)}.not_to raise_error
  end

  context 'once prepended' do
    before :each do
      @target_class.send(:prepend, Sereth::JsonSpec)
      @target = @target_class.new
    end

    context 'class methods' do
      it 'path generator' do
        @target_class.json_spec_path.should == ''
      end

      it 'schema generator' do
        Sereth::JsonSpec::Data.expects(:export).
          with('', :test, kind_of(Sereth::JsonSpec::DummyUtil)).once.returns(:pass)
        @target_class.json_spec_schema(:test).should == :pass
      end

      it 'schema iterator' do
        Sereth::JsonSpec::Data.expects(:each).with('').once.returns(:pass).yields(:pass)
        yielded = nil
        @target_class.each_json_spec do |val|
          yielded = val
        end
        yielded.should == :pass
      end

      it 'spec generator' do
        Sereth::JsonSpec::Data.expects(:generate).with('', :test).once.yields(:pass)
        yielded = nil
        @target_class.json_spec(:test) do |val| 
          yielded = val
        end
        yielded.should == :pass
      end
    end

    context 'inst methods' do
      it 'to_json without spec requests' do
        @target.to_json
      end

      it 'to_json with spec request' do
        Sereth::JsonSpec::Data.expects(:export).with('', :test, @target).once.returns(:pass)
        @target.to_json(:spec => :test).should == :pass
      end

      it 'as_json exporting to_json to RunnerUtil' do
        Sereth::JsonSpec::Data.expects(:export).with('', :test, @target).once.returns(:pass)
        @target.as_json(:spec => :test).to_json.should == :pass
      end

    end
  end

  
end