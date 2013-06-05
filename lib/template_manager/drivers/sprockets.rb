module Sereth
  require_relative './tilt'
  ::Sprockets.register_engine '.rtm', TunnelTemplate
end