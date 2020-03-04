# frozen_string_literal: true
require_relative '../id58_test_base'
require_relative 'capture_stdout_stderr'
require_src 'app'
require_src 'externals'

class TestBase < Id58TestBase
  include CaptureStdoutStderr
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

  def status?(expected)
    status === expected
  end

  def status
    last_response.status
  end

end
