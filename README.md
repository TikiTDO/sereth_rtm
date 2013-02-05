# Sereth JSON Perspectives

  Sereth JSON Perspectives is a rails plugin which hooks into any existing data store
  such as ActiveRecord, Mongoid, or even bare classes, and allows a developer to
  define a set of JSON message types to be exported to a client.

  The library may also be used to generate examples of blank data types to populate
  scripts, and to export to web-based API editors.
  
# Result

  A spec is defined on a ruby model. While this may be against Rails design
  principles, there is no easy way to accomplish all required features in views.

  > TODO: Allow for imports from views into the model classes

## Initialization
  Perspectives are assigned to classes as follows:
```ruby
class Data
  # Some record initialization
  # ...

  # Perspective initializations
  json_spec :name[, path] do
    # Configuration for data_inst.as_json(:spec => :name)
  end
end
```

### Perspective Path Gotcha
  The system will store all names spec at a given path. If path is not specified
  it will try to generate it from the collection name of the data object, or failing that
  the class name of the object.

  This means that any specs used in objects without collection names, and without
  a hard-coded path will overwrite other similarly named specs.


## API Reference
  Note, all values pass through `.to_json(spec: p_name)` unless otherwise noted
```ruby
json_spec p_name[, path] do
  ## Nodes
  # Key-Value Nodes
  node_name #=> "node_name": #{inst.node_name}
  node_name proc #=> "node_name": #{inst.instance_exec(&proc)}

  node_name Array #=> "node_name": [#{inst.node_name.each {|val| val}}]
  node_name Array, :gen #=> "node_name": [#{inst.node_name.each(&:gen)}]
  node_name Array, proc #=> "node_name": [#{inst.node_name.each(&proc)}]

  # Sub-spec nodes
  key_value_definition do
    # Unnamed JSON Spec definition in the context of resultant object
  end #=> "key_value_name": {#{json_spec_inst.parse(val)}}
      #=> "key_value_name_arr": [{#{json_spec_inst.parse(val)}}]

  ## Options
  # Overrides
  json_options.override, p_name[, path] # Apply new definitions over existing spec
end
```

## Basic Nodes
  Raw data nodes can be named within the json_spec block
```ruby
# Definition
json_spec :basic do
  id
end

# Result
data_inst.to_json(spec: basic) #=> {"id": "#{data_inst.id.to_json}"}  
```

  More fine grained control of the node value can be achieved with lambdas
```ruby
# Definition
json_spec :basic_proc do
  id lambda {self.other_id}
end

# Result
data_inst.to_json(spec: basic_proc) #=> {"id": "#{data_inst.other_id.to_json}"}  
```

## Collections
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
  If a specified value is not an array, it will be added to a single-element Array.
```ruby
# Assume
data_inst.key = "asdf"

# Definition
json_spec :col_non_array do
  key Array
end

# Result
data_inst.to_json(spec: col_non_array) #=> "{"key": ["asdf"]}"
```

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


## Objects
  New objects may be embedded in an existing spec as blocks.

```ruby
json_spec :obj do

end
``` 

### Sub-objects
  **Note*** - If not denoted, the entire collection will be parsed into a single value and 
  will be passed to the instance handler.
```ruby
# WRONG Definition
json_spec :ex5 do
  nodes Array do
    # This will 
  end
end

# Result - Note the quoted array
# data_inst.to_json(spec: ex4) #=> {"nodes": "[node1, node2...]"}
```