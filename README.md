# Sereth JSON Perspectives

  Sereth JSON Perspectives is a rails plugin based on the idea of treating models like
  API objects exported through JSON. It breaks with the rails convention of treating
  these objects as views, and instead defines different perspectives as core features
  of the data model. 

  The library may also be used to generate examples of blank data schemas to populate
  scripts, and to export to web-based API editors.
  
## Content
1. [Usage](#usage)
  - [Initialization](#initialization)
  - [Utilization](#utilization)
  - [Schemas](#schemas)
2. [API Overview](#api-overview)
  - [Basic Nodes](#basic-nodes)
      * [Typed Nodes](#typed-values)
      * [Dynamic Nodes](#dynamic-nodes)
      * [Default Values](#default-values)
  - [Collections](#collections)
      * [Non-Array Collections](#non-array-collections)
      * [Dynamic Collections](#dynamic-collections)
  - [Objects](#objects)
      * [Object Collections](#object-collections)
      * [Glue Object](#glue-object)
      * [Object Extension](#object-extension)
  - [Overrides](#overrides)
  - [Conditionals/Execution break-in](#conditionalsexecution-break-in)

## Design Considerations

  A spec is defined on a ruby model. While this may be against Rails design
  principles, there is no easy way to accomplish all required features in views.

  > TODO: Allow for imports from views into the model classes. On access to the
  > to_json method compile all views for this object, and cache these values to
  > the model proper.

## Usage
### Initialization
  Perspectives are configured within the scope of the Data object class. See the 
  [API](#api-overview) for configuration options.
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
```ruby
  render :json => data_inst.as_json(:spec => :name)
  # OR
  render :text => data_inst.to_json(:spec => :name)  
```

### Schemas
  The system may be used to generate an empty JSON schema, which lays out the key names,
  and JSON level data types (objects, arrays, values).
```ruby
  Data.json_spec_schema(:name)
```

  **Note**: In the future this feature may be expanded to provide info about value data types,
  size constraints, and other bits of info that may be useful in an online API editor.


### Perspective Path Gotcha
  The system will store all names spec at a given path. If path is not specified
  it will try to generate it from the collection name of the data object, or failing that
  the class name of the object.

  This means that any specs used in objects without collection names, and without
  a hard-coded path will overwrite other similarly named specs.

##
## API Overview
##
  Note, all values pass through `.to_json` unless otherwise noted
```ruby
json_spec spec_name do
  ## Nodes
  # Key-Value Nodes
  node_name #=> "node_name": #{inst.node_name}
  node_name :gen #=> "node_name": #{inst.gen)}
  node_name proc #=> "node_name": #{inst.instance_eval(&proc)}

  # Key-Array Nodes
  node_name Array #=> "node_name": [#{inst.node_name.each {|val| val}}]
  node_name Array, :gen #=> "node_name": [#{inst.node_name.each(&:gen)}]
  node_name Array, proc #=> "node_name": [#{inst.node_name.each(&proc)}]

  # Key-Object Nodes 
  node_name do ... end 
    #=> "node_name": {#{json_spec.from(&block).apply(inst.node_name)}}

  # Key-Object Collections
  node_name Array do ... end 
    #=> "node_name": [#{inst.node_name.each {|item| json_spec.from(&block).apply(item)}}]

  ## Operations
  override! :node_name, ... # Same functionality as above, but allows for restricted names
  extends! (DataClass or "collection_name" or :spec_name)[, :spec_name] # Utilize a spec for nodes specified there and not in this context
  if! proc do ... end # Executes the proc in the context of the inst, then runs any present block in the current definition context if the proc return value evalutates to true
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
data_inst.to_json(spec: :basic) 
  #=> {"id": #{data_inst.id.to_json}}


# Schema Result
Data.json_spec_schema(:typed)
  #=> {"id": "BasicValue"}  
```

### Typed Nodes
  Raw data nodes may specify a data type. This will ensure the resulting data is of a given
  data type before generating the JSON object. 

  Generating a schema from a typed node will set the value of the node to that type.
```ruby
# Definition
json_spec :typed do
  id Integer
end

# Result
data_inst.to_json(spec: :typed) 
  #=> {"id": #{data_inst.id.to_json}}  

# Schema Result
Data.json_spec_schema(:typed)
  #=> {"id": "Integer"}  
```

  **Important**: If the data type does not match the generator will emit an error. 
```ruby
# Definition
json_spec :typed_inval do
  not_a_string String
end

# Result
data_inst.to_json(spec: :typed_inval) 
  #=> Error: not_a_string fails data type contraints
```

  

### Dynamic Nodes
  More fine grained control of the node value can be achieved with procs
```ruby
# Definition
json_spec :basic_proc do
  id proc {other_id}
  tag :email
end

# Result
data_inst.to_json(spec: :basic_proc) 
  #=> {
    # "id": "#{data_inst.other_id.to_json}",  
    # "tag": #{data_inst.email.to_json}}
```

### Default Values
The Dynamic Node generation may also supply default values

```ruby
# Definition
json_spec :basic_def do
  word proc {"hello"}
end

# Result
data_inst.to_json(spec: :basic_def) 
  #=> {"word": #{"hello".to_json}}
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
data_inst.to_json(spec: :col) #=> {"nodes": [node1.to_json, node2.to_json...]}  

# Schema Result
Data.json_spec_schema(:typed)
  #=> {"id": [... collection_schema ...]}  
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
data_inst.to_json(spec: :col_non_array) #=> "{"key": ["asdf".to_json]}"
```

### Typed Collections
  All the data nodes in a collection may specify a data type. This will ensure that all members
  of the collection are of a given data type before generating the JSON object. Note, when 
  specifying a typed collection the first value of the type **must** be Array.

  Generating a schema from a typed collection will set the element of that collection to that type

  **Important**: If the data type does not match the generator will emit an error.
```ruby
# Definition
json_spec :typed do
  post_ids [Array, Integer], proc {posts.map(&:id)}
end
```

### Dynamic Collections
  Collection generation may be extended with blocks or generator functions.
```ruby
# Definition
json_spec :col_block do
  nodes Array, :get
  others Array, proc {gen_other}
end

# Result
data_inst.to_json(spec: :col_block) #=> {
  # "nodes": [node1.get.to_json, node2.get.to_json...],
  # "others": [gen_other1.to_json, gen_other2.to_json...]}
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
  other_key proc {real_other_key} do
    node_name_b
  end
  no_key do 
    node_name_c
  end

end

# Result
data_inst.to_json(spec: :obj) #=> "{
  #"key": {"node_name_a": "#{data_inst.key.node_name_a.to_json}"},
  #"other_key": {"node_name_b": "#{data_inst.real_other_key.node_name_b.to_json}"},
  #"no_key": {"node_name_b": "#{data_inst.node_name_c.to_json}"}

# Schema Result
Data.json_spec_schema(:typed)
  #=> {"id": [... object_schema ...]}  
``` 


### Object Collections
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
  use the proc object definition, or the special glue! command.

```ruby
# Assume
class Data
  has_attribute :key_a, :key_b
end

# Definition
json_spec :obj_glue do
  key_a proc {self} do
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

### Object Extension
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

***Important*** - Each block may be extended only once. New extensions override the prior ones.

##
## Overrides
##
  Sometimes a node_name will be defined in the global ruby function scope. In this situation the
  override method allows direct access to above features using a hard-coded function.

```ruby
# Definition
json_spec :ovr do
  override! :print
end

# Result
data_inst.to_json(spec: :ovr) 
#=> {"print": #{data_inst.print.to_json}
```

##
## Conditionals/Execution break-in
##
  Occasionally some nodes may be conditionally required based on some outside criteria.
  For this purpose the json_spec supports operators to break directly into the 
  execution of the spec generator.

  ***Note*** - All conditionals are executed within the context of the data_inst.
```ruby
# Definition
json_spec :cond do
  if!(proc {some_check}) do
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
