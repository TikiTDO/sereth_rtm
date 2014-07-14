# Rails Model
class Model
  field :var_name, type: String

  has_many :multi

  json_spec 'spec_name' do
    var_name
    multi_ids Array, get: proc {multi.map(&:id)}
    multi do
      id
      name
    end
  end
end

# Rails Controller
class Controller
  def action
    @model_inst.to_json(spec: 'spec_name')
  end
end

# Rails View
lang(:coffee) do
  model = sereth.bind('model', 'url')
  inst = model.get('spec_name')
  inst = request 'spec_name'
  inst.get(url)
end

# What do we want out of the view compontnet
#  Instantiate sever elements locally 
#    Bind an object to a URL
#    
#  Update server elements as needed
#  Have server guide in local element structure
#  Request elements by spec
#    Show element structure in editing panels