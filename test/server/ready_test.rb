# frozen_string_literal: true
require_relative 'custom_test_base'

class ReadyTest < CustomTestBase

  def self.id58_prefix
    'A86'
  end

  include Rack::Test::Methods

  # - - - - - - - - - - - - - - - - -

  test '15D',
  %w( its ready if custom-start-points and saver are both ready ) do
    get '/ready'
    assert last_response.ok?
    assert_equal '{"ready?":true}', last_response.body
  end

end
