# frozen_string_literal: true

require_relative 'custom_start_points_service'
require_relative 'saver_service'
require_relative 'time_adapter'
require_relative 'random_adapter'

class Externals

  def custom_start_points
    @custom_start_points ||= CustomStartPointsService.new(self)
  end

  def saver
    @saver ||= SaverService.new(self)
  end

  def http
    @http ||= Net::HTTP
  end

  def time
    @time ||= TimeAdapter.new
  end

  def random
    @random ||= RandomAdapter.new    
  end

end
