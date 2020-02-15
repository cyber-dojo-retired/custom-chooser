# frozen_string_literal: true
require_relative '../id58_test_base'
require_src 'custom'
require_src 'externals'

class CustomTestBase < Id58TestBase
  include Rack::Test::Methods

  def initialize(arg)
    super(arg)
  end

  def externals
    @externals ||= Externals.new
  end

  def app
    @app ||= Custom.new(nil, externals)
  end

  def browser
    @browser ||= Rack::Test::Session.new(Rack::MockSession.new(app))
  end

end
