# frozen_string_literal: true

require_relative 'services/custom_start_points'
require_relative 'services/saver'
require_relative 'services/time'

class Externals

  def custom_start_points
    @custom_start_points ||= CustomStartPoints.new(http)
  end

  def saver
    @saver ||= Saver.new(http)
  end

  def http
    @http ||= Net::HTTP
  end

  def time
    @time ||= Time.new
  end

  def random
    @random ||= Random
  end

end
