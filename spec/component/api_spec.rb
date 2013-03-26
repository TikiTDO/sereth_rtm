require 'spec_helper'

describe :api do
  before :each do
    @target_class = Class.new
    @target_class.send(:define_method, :to_json) {|*options| :default}
  end

  it 'include in class' do
    expect {@target_class.send(:include, Sereth::JsonSpec)}.to raise_error
  end

  it 'prepend in class' do
    expect {@target_class.send(:prepend, Sereth::JsonSpec)}.not_to raise_error
  end

  context 'once injected' do
    before :each do
      @target_class.send(:prepend, Sereth::JsonSpec)
      @target = @target_class.new
    end

    ## Injected Class Methods
    it 'path generator' do
      @target_class.json_spec_path.should == ''
    end

    it 'schema generator' do
      Sereth::JsonSpec::Data.expects(:export).once.returns(:pass)
    end

    ## Injected Instance Methods
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