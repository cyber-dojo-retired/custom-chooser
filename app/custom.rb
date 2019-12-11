# frozen_string_literal: true

require_relative 'id_generator'
require_relative 'id_pather'
require_relative 'json_plain'
require_relative 'saver_asserter'
require 'sinatra/base'
require 'sprockets'
#require 'uglifier'

class Custom < Sinatra::Base

  set :port, ENV['PORT']
  set :environment, Sprockets::Environment.new
  environment.append_path 'assets/stylesheets'
  environment.append_path 'assets/javascripts'
  #environment.js_compressor  = Uglifier.new(harmony: true)
  environment.css_compressor = :scss

  after do
    response['Connection'] = 'Close'
  end

  def initialize(app = nil, externals)
    super(app)
    @externals = externals
  end

  get '/sha' do
    content_type :json
    { 'sha': ENV['SHA'] }.to_json
  end

  get '/alive' do
    content_type :json
    { "alive?": true }.to_json
  end

  get '/ready' do
    content_type :json
    { "ready?": start_points.ready? && saver.ready? }.to_json
  end

  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  get '/show' do
    @display_names = start_points.names
    @from = params['from']
    erb :show
  end

  get '/save_individual' do
    manifest = starter_manifest
    id = create_kata(manifest)
    redirect "/kata/edit/#{id}"
  end

  private

  include IdPather
  include SaverAsserter

  def starter_manifest
    name = params['display_name']
    manifest = start_points.manifest(name)
    manifest['created'] = time.now
    manifest['version'] = 1
    manifest
  end

  def create_kata(manifest)
    id = manifest['id'] = IdGenerator.new(@externals).kata_id
    manifest['version'] = 1
    event_summary = {
      'index' => 0,
      'time' => manifest['created'],
      'event' => 'created'
    }
    event0 = {
      'files' => manifest['visible_files']
    }
    saver_assert_batch(
      manifest_write_cmd(id, json_plain(manifest)),
      events_write_cmd(id, json_plain(event_summary)),
      event_write_cmd(id, 0, json_plain(event0.merge(event_summary)))
    )
    id
  end


  #- - - - - - - - - - - - - - - - - - - - - - -

  def manifest_write_cmd(id, manifest_src)
    ['write', manifest_filename(id), manifest_src]
  end

  def manifest_filename(id)
    id_path(id, 'manifest.json')
  end

  def events_write_cmd(id, event0_src)
    ['write', events_filename(id), event0_src]
  end

  def events_filename(id)
    id_path(id, 'events.json')
  end

  def event_write_cmd(id, index, event_src)
    ['write', event_filename(id,index), event_src]
  end

  def event_filename(id, index)
    id_path(id, "#{index}.event.json")
  end

  def id_path(id, *parts)
    kata_id_path(id, *parts)
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  def start_points
    @externals.custom_start_points
  end

  def saver
    @externals.saver
  end

  def time
    @externals.time
  end

end
