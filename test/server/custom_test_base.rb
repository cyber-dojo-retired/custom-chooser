# frozen_string_literal: true
require_relative '../id58_test_base'
require_src 'app'
require_src 'externals'

class CustomTestBase < Id58TestBase
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

end
