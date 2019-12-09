$stdout.sync = true
$stderr.sync = true

require 'rack'
use Rack::Lint
use Rack::Deflater

unless ENV['NO_PROMETHEUS']
  require 'prometheus/middleware/collector'
  require 'prometheus/middleware/exporter'
  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter
end

require_relative 'externals'
externals = Externals.new
require_relative 'custom'
run Custom.new(nil,externals)
