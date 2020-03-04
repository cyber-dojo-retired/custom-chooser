# frozen_string_literal: true
require_relative 'test_base'
require_relative 'external_saver'
require_relative 'id_pather'
require_src 'external_http'
require 'json'

class CreateTest < TestBase

  def self.id58_prefix
    'v42'
  end

  # - - - - - - - - - - - - - - - - -

  test '7Je', %w( GET/assets/app.css is served ) do
    get '/assets/app.css'
    assert status?(200), status
    assert css_content?, content_type
  end

  test '7Jf', %w( GET/assets/app.js is served ) do
    get '/assets/app.js'
    assert status?(200), status
    assert js_content?, content_type
  end

  # - - - - - - - - - - - - - - - - -

  test 'w9A', %w(
  |GET /create_group?display_name=...
  |redirects to /kata/group/:id page
  |and a group with :id exists
  ) do
    display_name = any_display_name
    get '/create_group', :display_name => display_name
    assert status?(302), status
    follow_redirect!
    assert html_content?, content_type
    url = last_request.url # eg http://example.org/kata/group/xCSKgZ
    assert %r"http://example.org/kata/group/(?<id>.*)" =~ url, url
    assert group_exists?(id), "id:#{id}:" # eg xCSKgZ
    manifest = group_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
  end

  # - - - - - - - - - - - - - - - - -

  test 'w9B', %w(
  |GET /create_kata?display_name=...
  |redirects to /kata/edit/:id page
  |and a kata with :id exists
  ) do
    display_name = any_display_name
    get '/create_kata', :display_name => display_name
    assert status?(302), status
    follow_redirect!
    assert html_content?, content_type
    url = last_request.url # eg http://example.org/kata/edit/H3Nqu2
    assert %r"http://example.org/kata/edit/(?<id>.*)" =~ url, url
    assert kata_exists?(id), "id:#{id}:" # eg H3Nqu2
    manifest = kata_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
  end

  # - - - - - - - - - - - - - - - - -

  test 'w9C', %w(
  |POST /create_group body={"display_name":"..."}
  |returns json payload
  |with {"create_group":"ID"}
  |where a group with ID exists
  |and for backwards compatibility
  |also returns the ID against an "id" key
  ) do
    display_name = any_display_name
    json_post path='create_group', {display_name:display_name}
    assert status?(200), status
    assert json_content?, content_type
    assert_equal [path,'id'], json_response.keys.sort, :keys
    id = json_response['id'] # eg xCSKgZ
    assert group_exists?(id), "id:#{id}:"
    manifest = group_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
  end

  # - - - - - - - - - - - - - - - - -

  test 'w9D', %w(
  |POST /create_kata body={"display_name":"..."}
  |returns json payload
  |with {"create_kata":"ID"}
  |where a kata with ID exists
  |and for backwards compatibility
  |also returns the ID against an "id" key
  ) do
    display_name = any_display_name
    json_post path='create_kata', {display_name:display_name}
    assert status?(200), status
    assert json_content?, content_type
    assert_equal [path,'id'], json_response.keys.sort, :keys
    id = json_response['id'] # eg H3Nqu2
    assert kata_exists?(id), "id:#{id}:"
    manifest = kata_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
  end

  private

  def any_display_name
    display_names.sample
  end

  # - - - - - - - - - - - - - - - - - - - -

  include IdPather

  def group_exists?(id)
    saver.exists?(group_id_path(id))
  end

  def kata_exists?(id)
    saver.exists?(kata_id_path(id))
  end

  # - - - - - - - - - - - - - - - - - - - -

  def group_manifest(id)
    JSON::parse!(saver.read("#{group_id_path(id)}/manifest.json"))
  end

  def kata_manifest(id)
    JSON::parse!(saver.read("#{kata_id_path(id)}/manifest.json"))
  end

  # - - - - - - - - - - - - - - - - - - - -

  def saver
    ExternalSaver.new(http)
  end

  def http
    ExternalHttp.new
  end

  # - - - - - - - - - - - - - - - - - - - -

  def json_post(path, data)
    post '/'+path, data.to_json, JSON_REQUEST_HEADERS
  end

  JSON_REQUEST_HEADERS = {
    'CONTENT_TYPE' => 'application/json', # request sent by client
    'HTTP_ACCEPT' => 'application/json'   # response received by client
  }

  # - - - - - - - - - - - - - - - - - - - -

  def json_response
    @json_response ||= JSON.parse(last_response.body)
  end

  # - - - - - - - - - - - - - - - - - - - -

  def html_content?
    content_type === 'text/html;charset=utf-8'
  end

  def json_content?
    content_type === 'application/json'
  end

  def css_content?
    content_type === 'text/css; charset=utf-8'
  end

  def js_content?
    content_type === 'application/javascript'
  end

  def content_type
    last_response.headers['Content-Type']
  end

end
