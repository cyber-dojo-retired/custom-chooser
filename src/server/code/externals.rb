# frozen_string_literal: true
require_relative 'services/creator'
require_relative 'services/custom_start_points'

class Externals

  def creator
    @creator ||= Creator.new(http)
  end

  def custom_start_points
    @custom_start_points ||= CustomStartPoints.new(http)
  end

  def http
    @http ||= Net::HTTP
  end

end
