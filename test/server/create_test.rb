# frozen_string_literal: true
require_relative 'custom_test_base'
require_relative 'external_saver'
require_relative 'id_pather'
require_src 'external_http'
require 'json'

class CreateTest < CustomTestBase

  def self.id58_prefix
    'v42'
  end

  # - - - - - - - - - - - - - - - - -

  test 'w9A', %w(
  |GET /create_group?display_name=...
  |redirects to /kata/group/:id page
  |and a group with :id exists
  ) do
    display_name = any_display_name
    get '/create_group', :display_name => display_name
    assert_status 302
    follow_redirect!
    path = last_request.url # eg http://example.org/kata/group/xCSKgZ
    assert %r"http://example.org/kata/group/(?<id>.*)" =~ path, path
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
    assert_status 302
    follow_redirect!
    path = last_request.url # eg http://example.org/kata/edit/H3Nqu2
    assert %r"http://example.org/kata/edit/(?<id>.*)" =~ path, path
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
  |also returns the ID against an :id key
  ) do
    display_name = any_display_name
    json_post path='create_group', {display_name:display_name}
    assert_status 200
    assert_json_content
    assert_equal [path,'id'], json_response.keys.sort, :keys
    id = json_response['id']
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
  |also returns the ID against an :id key
  ) do
    display_name = any_display_name
    json_post path='create_kata', {display_name:display_name}
    assert_status 200
    assert_json_content
    assert_equal [path,'id'], json_response.keys.sort, :keys
    id = json_response['id']
    assert kata_exists?(id), "id:#{id}:"
    manifest = kata_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
  end

  private

  def any_display_name
    custom_start_points.display_names.sample
  end

  def custom_start_points
    externals.custom_start_points
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
    'CONTENT_TYPE' => 'application/json', # sent request
    'HTTP_ACCEPT' => 'application/json'   # received response
  }

  # - - - - - - - - - - - - - - - - - - - -

  def json_response
    @json_response ||= JSON.parse(last_response.body)
  end

  def assert_status(expected)
    assert_equal expected, last_response.status, :last_response_status
  end

  def assert_json_content
    assert_equal 'application/json', last_response.headers['Content-Type']
  end

end
