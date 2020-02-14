$stdout.sync = true
$stderr.sync = true

unless ENV['NO_PROMETHEUS']
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'
  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter
end

require_relative 'code/externals'
require_relative 'code/custom'
require 'rack'
externals = Externals.new
custom = Custom.new(nil, externals)
run custom
