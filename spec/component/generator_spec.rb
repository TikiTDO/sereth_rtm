require 'spec_helper'

describe :generator do
  before :each do
    @mock_data = mock()
  end

  it 'object initialization' do
    expect{Sereth::JsonSpec::Generator.new('path', 'name', @mock_data)}.not_to raise_error
  end

  context 'after initialization' do
    before :each do
      @gen = Sereth::JsonSpec::Generator.new('path', 'name', @mock_data)
    end

    it 'generates basic node' do
      @mock_data.stubs(:command!).once.
        with(:test_node, false, nil, {type: nil, get: :test_node, set: nil})
      @gen.test_node
    end

    it 'generates basic collection node' do
      @mock_data.stubs(:command!).
        with(:test_node, true, nil, {type: nil, get: :test_node, set: nil})
      @gen.test_node Array
    end

    it 'generates object nodes' do
      subnode_mock_data = mock();
      Sereth::JsonSpec::Data.expects(:new).once.returns(subnode_mock_data)

      @mock_data.stubs(:command!).once.
        with(:test_node, false, subnode_mock_data)
      @gen.test_node do end
    end


    it 'generates object collection nodes' do
      subnode_mock_data = mock();
      Sereth::JsonSpec::Data.expects(:new).once.returns(subnode_mock_data)

      @mock_data.stubs(:command!).once.
        with(:test_node, true, subnode_mock_data)
      @gen.test_node Array do end
    end
  end
end