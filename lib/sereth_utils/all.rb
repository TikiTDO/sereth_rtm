require 'rubygems'
require 'pry'
require 'andand'
require 'sourcify'

# Use staging for all following code.
require_relative './stage'
require_relative './alias_args'
require_relative './callbacks'

Seret::Stage.run_stage(:sereth_util_loaded)