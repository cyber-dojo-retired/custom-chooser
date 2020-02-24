# frozen_string_literal: true
require_relative 'externals_creator'
require_relative 'externals_custom_start_points'

class Externals

  def creator
    @creator ||= ExternalsCreator.new(http)
  end

  def custom_start_points
    @custom_start_points ||= ExternalsCustomStartPoints.new(http)
  end

  def http
    @http ||= Net::HTTP
  end

end
