# frozen_string_literal: true
require_relative 'test_base'

class IndexTest < TestBase

  def self.id58_prefix
    'a73'
  end

  # - - - - - - - - - - - - - - - - -

  test '18w', %w(
  |GET/index_group
  |offers all display_names
  |ready to create a group
  |when custom_start_points is online
  ) do
    get '/index_group'
    assert status?(200), status
    html = last_response.body
    assert heading(html).include?('our'), html
    refute heading(html).include?('my'), html
    display_names.each do |display_name|
      assert html =~ div_for(display_name), display_name
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '19w', %w(
  |GET/index_kata
  |offers all display_names
  |ready to create a kata
  |when custom_start_points is online
  ) do
    get '/index_kata'
    assert status?(200), status
    html = last_response.body
    assert heading(html).include?('my'), html
    refute heading(html).include?('our'), html
    display_names.each do |display_name|
      assert html =~ div_for(display_name), display_name
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'F8k', %w(
  |GET/index_group
  |is error 500
  |when custom_start_points is offline
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
  |GET/index_kata
  |is error 500
  |when custom_start_points is offline
  ) do
    stub_custom_start_points_http(not_json='xxxx')
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

  #- - - - - - - - - - - - - - - - - - - - - -

  def heading(html)
    # (.*?) for non-greedy match
    # /m for . matching newlines
    html.match(/<div id="heading">(.*?)<\/div>/m)[1]
  end

  def div_for(display_name)
    # eg cater for "C++ Countdown, Round 1"
    plain_display_name = Regexp.quote(display_name)
    /<div class="display-name">\s*#{plain_display_name}\s*<\/div>/
  end

end
