# frozen_string_literal: true
require_relative 'custom_test_base'
require_relative 'external_saver'
require_relative 'id_pather'
require_src 'external_http'

class CreateTest < CustomTestBase

  def self.id58_prefix
    'v42'
  end

  # - - - - - - - - - - - - - - - - -

  test 'w9A', %w(
  |GET /create_group?display_name=DISPLAY_NAME
  |redirects to /kata/group/:id page
  |and a group with :id exists
  ) do
    display_name = 'Java Countdown, Round 1'
    get '/create_group', :display_name => display_name
    assert_equal 302, last_response.status, :status_302
    follow_redirect!
    path = last_request.url # eg http://example.org/kata/group/xCSKgZ
    assert %r"http://example.org/kata/group/(?<id>.*)" =~ path, path
    assert group_exists?(id), "id:#{id}:" # eg xCSKgZ
    manifest = group_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
  end

  # - - - - - - - - - - - - - - - - -

  test 'w9B', %w(
  |GET /create_kata?display_name=DISPLAY_NAME
  |redirects to /kata/edit/:id page
  |and a kata with :id exists
  ) do
    display_name = 'Java Countdown, Round 2'
    get '/create_kata', :display_name => display_name
    assert_equal 302, last_response.status, :status_302
    follow_redirect!
    path = last_request.url # eg http://example.org/kata/edit/H3Nqu2
    assert %r"http://example.org/kata/edit/(?<id>.*)" =~ path, path
    assert kata_exists?(id), "id:#{id}:" # eg H3Nqu2
    manifest = kata_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
  end

  private

  include IdPather

  def group_exists?(id)
    saver.exists?(group_id_path(id))
  end

  def group_manifest(id)
    JSON::parse!(saver.read("#{group_id_path(id)}/manifest.json"))
  end

  # - - - - - - - - - - - - - - - - - - - -

  def kata_exists?(id)
    saver.exists?(kata_id_path(id))
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

end
