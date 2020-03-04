# frozen_string_literal: true
require_relative 'test_base'

class ResponseErrorTest < TestBase

  def self.id58_prefix
    'q7E'
  end

  # - - - - - - - - - - - - - - - - -

  test 'F8k', %w(
  |any http-service call
  |is 500 error
  |when response's json.body is not JSON
  ) do
    stub_custom_start_points_http(not_json='xxxx')
    _stdout,_stderr = capture_stdout_stderr {
      get '/index_group'
    }
    assert status?(500), status
    #...
  end

  # - - - - - - - - - - - - - - - - -

  test 'F9k', %w(
  |any http-service call
  |is 500 error
  |when response's json.body is not JSON-Hash
  ) do
    stub_custom_start_points_http(not_json_hash='[]')
    _stdout,_stderr = capture_stdout_stderr {
      get '/index_kata'
    }
    assert status?(500), status
    #...
  end

  # - - - - - - - - - - - - - - - - -

  test 'F9p', %w(
  |any http-serice call
  |is 500 error
  |when response's json.body has embedded exception
  ) do
    stub_custom_start_points_http(exception='{"exception":"xxx"}')
    _stdout,_stderr = capture_stdout_stderr {
      get '/index_kata'
    }
    assert status?(500), status
    #...
  end

  # - - - - - - - - - - - - - - - - -

  test 'F9q', %w(
  |any http-servive call
  |is 500 error
  |when response's json.body has no key for method
  ) do
    stub_custom_start_points_http(no_key='{}')
    _stdout,_stderr = capture_stdout_stderr {
      get '/index_kata'
    }
    assert status?(500), status
    #...
  end

  private

  def stub_custom_start_points_http(body)
    externals.instance_exec {
      @custom_start_points_http = HttpAdapterStub.new(body)
    }
  end

  class HttpAdapterStub
    def initialize(body)
      @body = body
    end
    def get(_uri)
      OpenStruct.new
    end
    def start(_hostname, _port, _req)
      self
    end
    attr_reader :body
  end

end
