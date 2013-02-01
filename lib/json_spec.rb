class JsonSpec
  attr_accessible
  def initialize(data)
    @data = data
    @options = {}
  end
end
