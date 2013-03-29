# Spork Config
require 'rubygems'
require 'spork'

Spork.prefork do
  require 'json'
end

Spork.each_run do
  require 'sereth_json_spec'
end

# RSpec Config
require 'rspec/autorun'
require 'mocha/api'

RSpec.configure do |config|
  config.mock_with :mocha
end
