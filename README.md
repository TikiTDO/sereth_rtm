# Sereth JSON Perspectives

  Sereth JSON Perspectives is a rails plugin which hooks into any existing data store
  such as ActiveRecord, Mongoid, or even bare classes, and allows a developer to
  define a set of JSON message types to be exported to a client.

  The library may also be used to generate examples of blank data types to populate
  scripts, and to export to web-based API editors.
  
## Design Considerations

  A spec is defined on a ruby model. While this may be against Rails design
  principles, there is no easy way to accomplish all required features in views.

  > TODO: Allow for imports from views into the model classes. On access to the
  > to_json method compile all views for this object, and cache these values to
  > the model proper.

## Usage
### Initialization
  Perspectives are assigned to classes as follows:
```ruby
class Data
  # Some record initialization
  # ...

  # Perspective initializations
  json_spec :name do
    # Configuration for data_inst.as_json(:spec => :name)
  end
end
```

### Utilization
May be used to render raw JSON data as text. 
***Note*** - For performance reasons, an option to generate a Ruby object for JSON
export is not provided. 

```ruby
  # Correct Way
  render :text => data_inst.to_json(:spec => :name)
  # Wrong Way!
  render :json => data_inst.to_json(:spec => :name)
```

May also be utilized to generate a JSON object outline with no values for use in
scripts and API editors

```ruby
  Data.blank_json_spec(:name)
```



### Perspective Path Gotcha
  The system will store all names spec at a given path. If path is not specified
  it will try to generate it from the collection name of the data object, or failing that
  the class name of the object.

  This means that any specs used in objects without collection names, and without
  a hard-coded path will overwrite other similarly named specs.

##
## API Reference
##
  Note, all values pass through `.to_json` unless otherwise noted
```ruby
json_spec p_name[, path] do
  ## Nodes
  # Key-Value Nodes
  node_name #=> "node_name": #{inst.node_name}
  node_name lambda #=> "node_name": #{inst.instance_exec(&lambda)}

  # Key-Array Nodes
  node_name Array #=> "node_name": [#{inst.node_name.each {|val| val}}]
  node_name Array, :gen #=> "node_name": [#{inst.node_name.each(&:gen)}]
  node_name Array, lambda #=> "node_name": [#{inst.node_name.each(&lambda)}]

  # Key-Object Nodes (inst.node_name NOT Collection)
  node_name do ... end 
    #=> "node_name": "{#{json_spec.from(node_inst.node_name, &block)}}""

  # Key-Object Nodes (inst.node_name IS Collection)
  node_name do ... end 
    #=> "node_name": "{#{node_inst.node_name {|item| json_spec.from(item, &block)}}}""

  ## Operations
  default! :node_name, (value or lambda) #=> "node_name": "#{value or lambda.call}"
  extends! (path or :p_name)[, :p_name] # Utilize a spec for nodes specified there and not in this context
end
```

##
## Basic Nodes
##
  Raw data nodes can be named within the json_spec block
```ruby
# Definition
json_spec :basic do
  id
end

# Result
data_inst.to_json(spec: basic) 
  #=> {"id": #{data_inst.id.to_json}}  
```

### Dynamic Nodes
  More fine grained control of the node value can be achieved with lambdas
```ruby
# Definition
json_spec :basic_proc do
  id lambda {other_id}
end

# Result
data_inst.to_json(spec: basic_proc) 
  #=> {"id": "#{data_inst.other_id.to_json}"}  
```

##
## Collections
##
  Collections must be denoted as such by speficying the Array data type after the node 
  name. 
```ruby
# Definition
json_spec :col do
  nodes Array
end

# Result
data_inst.to_json(spec: col) #=> {"nodes": [node1.to_json, node2.to_json...]}  
```

### Non-Array Collections
  If a specified value is not an array, it will be added to a single-element Array.
```ruby
# Assume
data_inst.key = "asdf"

# Definition
json_spec :col_non_array do
  key Array
end

# Result
data_inst.to_json(spec: col_non_array) #=> "{"key": ["asdf".to_json]}"
```

### Dynamic Collections
  Collection generation may be extended with blocks or generator functions.
```ruby
# Definition
json_spec :col_block do
  nodes Array, :get
  others Array, lambda {gen(1, 2)}
end

# Result
data_inst.to_json(spec: col_block) #=> {
  # "nodes": [node1.get.to_json, node2.get.to_json...],
  # "others": [other1.gen(1, 2).to_json, other2.gen(1, 2).to_json...]}
```

##
## Objects
##
  New objects may be embedded in an existing spec as blocks. The resulting context will
  determine if the data instance has a context of a given name, and will run within
  that context if present.

```ruby
# Assume
class Data
  has_attribute :key, :real_other_key
  not_an_attribute :no_key
end

# Definition
json_spec :obj do
  key do
    node_name_a
  end
  other_key lambda {real_other_key} do
    node_name_b
  end
  no_key do 
    node_name_c
  end

end

# Result
data_inst.to_json(spec: obj) #=> "{
  #"key": {"node_name_a": "#{data_inst.key.node_name_a.to_json}"},
  #"other_key": {"node_name_b": "#{data_inst.real_other_key.node_name_b.to_json}"},
  #"no_key": {"node_name_b": "#{data_inst.node_name_c.to_json}"}
``` 


### Objects Collections
  As with norman nodes, object nodes may be placed in a collection
```ruby
json_spec :obj_arr do
  node_name Array do
    key
  end
end

# Result
data_inst.to_json(spec: :obj_arr) 
  #=> {"node_name": [{"key": #{node1.key.to_json}}, {"key": #{node2.key.to_json}}...]}
```

### Glue Object
  Occasionally you may wish to create an object key for an existing attribute, but keep
  the context of the previous data object. There are two ways of doing this. You may
  use the lambda object definition, or the special glue! command.

```ruby
# Assume
class Data
  has_attribute :key_a, :key_b
end

# Definition
json_spec :obj_glue do
  key_a lambda {self} do
    node_name_a
  end
  glue! :key_b do
    node_name_b
  end
end

# Result
data_inst.to_json(spec: obj) #=> "{
  #"key_a": {"node_name_a": "#{data_inst.node_name_a.to_json}"}
  #"key_b": {"node_name_b: "#{data_inst.node_name_b.to_json}"}
```

### Extension
  If another json_spec defines some or all of the behaviour needed for a node, that 
  spec can be used as a starting basis for a new spec. The extended pec will provide
  provide all configuration values not otherwise overridden in the new spec.

```ruby
# Definition
json_spec :obj_ovr do
  default! :keep, 1
  default! :replace, 2
end

json_spec :obj_ext do
  extends! :ojbect_ovr
  replace
end

# Result
data_inst.to_json(spec: :obj_ext) #=> {"keep": 1, "replace": #{data_inst.replace.to_json}}
```

  Object extensions may also be performed of json_specs defined for different objects. 
  This is useful when generating a complex json which requires multiple interacting 
  models.

```ruby
# Assume
class Second
  has_association :first
end

# Definition
class First
  json_spec :obj_ovr_path do
    default! :key, 1
  end
end

class Second
  json_spec :obj_ext_path do
    first do
      extends! First, :obj_ovr_path
    end
  end
end

# Result
second_inst.to_json(spec: :obj_ext_path) #=> {"first": {"key": 1}}
```

## Conditionals - Execution break-in.
  Occasionally some nodes may be conditionally required based on some outside criteria.
  For this purpose the json_spec supports operators to break directly into the 
  execution of the spec generator.

  ***Note*** - All conditionals are executed within the context of the data_inst.
```ruby
# Definition
json_spec :cond do
  cond!(lambda {some_check}) do
    key
  end
end

# Result
data_inst.to_json(spec: :cond) 
#=> if data_inst.some_check
  # {"key": #{data_inst.key.jo_json}}
#=> if not data_inst.some_check
  # {}

```

## Caveats
  Redefining a node defined previously complete overrides it, even if done in the same 
  context. If complex node behaviour is required, please break it down into a proper
  series of extensions.
