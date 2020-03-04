# frozen_string_literal: true
require_relative '../id58_test_base'
require_src 'app'
require_src 'externals'

class TestBase < Id58TestBase
  include Rack::Test::Methods # [1]

  def initialize(arg)
    super(arg)
  end

  def externals
    @externals ||= Externals.new
  end

  def app
    App.new(externals) # [1]
  end

  def display_names
    custom_start_points.display_names
  end

  def custom_start_points
    externals.custom_start_points
  end

end
