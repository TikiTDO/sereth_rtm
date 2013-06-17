config_for :json_spec do
  alias_value :str, default: '', parse: proc {|raw| "#{raw}"}
  
  arg "-d #{str}", "--desc=#{str}", desc: "Pring something about a value"
end