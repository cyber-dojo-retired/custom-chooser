require_relative 'custom_start_points_service'

class Externals

  def custom_start_points
    @custom_start_points ||= CustomStartPointsService.new(self)
  end

  def http
    @http ||= Net::HTTP
  end

end
