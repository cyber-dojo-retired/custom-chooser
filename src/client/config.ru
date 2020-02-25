$stdout.sync = true
$stderr.sync = true

require_relative 'code/externals'
require_relative 'code/rack_dispatcher'
require 'rack'

externals = Externals.new
creator = externals.creator
dispatcher = RackDispatcher.new(creator, Rack::Request)
run dispatcher
