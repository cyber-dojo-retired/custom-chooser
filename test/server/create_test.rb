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

  def id58_setup
    @display_name = display_names.sample
  end

  attr_reader :display_name

  # - - - - - - - - - - - - - - - - -
  # 302
  # - - - - - - - - - - - - - - - - -

  test 'w9A', %w(
  |GET /group_create?display_names[]=...
  |redirects to /kata/group/:id page
  |and a group with :id exists
  ) do
    get '/group_create', display_names:[display_name]
    assert status?(302), status
    follow_redirect!
    assert html_content?, content_type
    url = last_request.url # eg http://example.org/kata/group/xCSKgZ
    assert %r"http://example.org/kata/group/(?<id>.*)" =~ url, url
    assert group_exists?(id), "id:#{id}:" # eg xCSKgZ
    manifest = group_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
    refute manifest.has_key?('exercise'), :exercise
  end

  # - - - - - - - - - - - - - - - - -

  test 'w9B', %w(
  |GET /kata_create?display_name=...
  |redirects to /kata/edit/:id page
  |and a kata with :id exists
  ) do
    get '/kata_create', display_name:display_name
    assert status?(302), status
    follow_redirect!
    assert html_content?, content_type
    url = last_request.url # eg http://example.org/kata/edit/H3Nqu2
    assert %r"http://example.org/kata/edit/(?<id>.*)" =~ url, url
    assert kata_exists?(id), "id:#{id}:" # eg H3Nqu2
    manifest = kata_manifest(id)
    assert_equal display_name, manifest['display_name'], manifest
    refute manifest.has_key?('exercise'), :exercise
  end

  # - - - - - - - - - - - - - - - - -
  # 500
  # - - - - - - - - - - - - - - - - -

  test 'Je4', %w(
  |GET/kata_create with unknown display_name
  |is 500 error
  ) do
    stdout,stderr = capture_stdout_stderr {
      get '/kata_create', display_name:'unknown'
    }
    verify_exception_info_on(stdout, 'http_service')
    assert_equal '', stderr, :stderr_is_empty
    assert status?(500), status
  end

  # - - - - - - - - - - - - - - - - -

  test 'Bq7', %w(
  |GET/group_create with extra parameter
  |is 500 error
  ) do
    stdout,stderr = capture_stdout_stderr {
      get '/kata_create', {
        display_name:display_name,
        extra:'wibble'
      }
    }
    verify_exception_info_on(stdout, 'message')
    assert_equal '', stderr, :stderr_is_empty
    assert status?(500), status
  end

  private

  def group_exists?(id)
    dirname = group_id_path(id)
    command = saver.dir_exists_command(dirname)
    saver.run(command)
  end

  def kata_exists?(id)
    dirname = kata_id_path(id)
    command = saver.dir_exists_command(dirname)
    saver.run(command)
  end

  include IdPather

  def verify_exception_info_on(stdout, name)
    json = JSON.parse!(stdout)
    assert_equal ['exception'], json.keys, stdout
    ex = json['exception']
    assert_equal ['request','backtrace',name].sort, ex.keys.sort, stdout
  end

  # - - - - - - - - - - - - - - - - - - - -

  def group_manifest(id)
    filename = "#{group_id_path(id)}/manifest.json"
    command = saver.file_read_command(filename)
    JSON::parse!(saver.run(command))
  end

  def kata_manifest(id)
    filename = "#{kata_id_path(id)}/manifest.json"
    command = saver.file_read_command(filename)
    JSON::parse!(saver.run(command))
  end

  # - - - - - - - - - - - - - - - - - - - -

  def saver
    ExternalSaver.new(http)
  end

  def http
    ExternalHttp.new
  end

end
