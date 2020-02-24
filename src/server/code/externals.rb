# frozen_string_literal: true
require_relative 'external_creator'
require_relative 'external_custom_start_points'
require_relative 'external_http'

class Externals

  def creator
    @creator ||= ExternalCreator.new(http)
  end

  def custom_start_points
    @custom_start_points ||= ExternalCustomStartPoints.new(http)
  end

  def http
    @http ||= ExternalHttp.new
  end

end
