# frozen_string_literal: true
require_relative '../id58_test_base'
require_src 'custom'

class CustomTestBase < Id58TestBase

  def initialize(arg)
    super(arg)
  end

  def app
    Custom
  end

  def browser
    @browser ||= Rack::Test::Session.new(Rack::MockSession.new(app))
  end

end
