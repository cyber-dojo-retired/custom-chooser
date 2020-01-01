$stdout.sync = true
$stderr.sync = true

unless ENV['NO_PROMETHEUS']
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'
  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter
end

require_relative 'externals'
externals = Externals.new
require_relative 'custom'
custom = Custom.new(nil,externals)
require 'rack'
run custom
