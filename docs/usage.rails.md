### Model Initialization
  Perspectives are configured within the scope of the Data object class. See the 
  [API](#api-overview) for configuration options.
```ruby
class Data
  # Some record initialization
  # ...
  
  # Enable JsonSpec for this object
  prepend Sereth::JsonTunnel
  
  # Perspective initializations
  json_spec :name do
    # Configuration for spec imports and exports
  end
end
```

### Controller Initialization
  A controller can be modified to detect tunnel requests on the show and index actions send
  from the client side of the tunnel.

  ***Note:*** This will create an around handler for show/index. Filter ordering applies.
```ruby
class DataController
  # Example data source to be rendered. Will run in the context of the controller instance
  data_source = proc {@data.where(:name => "test")}

  show_specs :index_spec_1, :index_spec_2..., &data_source # Block overrides option
  show_specs :index_spec_1, :index_spec_2..., source: data_source
  # OR
  index_specs :index_spec_1, :index_spec_2..., &data_source # Block overrides option
  index_specs :index_spec_1, :index_spec_2..., source: data_source
end
```

### Viewer Initialization
  Generate javascript tag to populate the client side tunnel interface with a reference to
  a specced object.

  ***Note:*** 
```ruby
script_tag = Data.json_tunnel(:spec_name, @default_inst)
```