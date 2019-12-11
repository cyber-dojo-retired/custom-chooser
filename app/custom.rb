# frozen_string_literal: true

require_relative 'create_group'
require_relative 'create_kata'
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

  get '/save_group' do
    id = create_group(starter_manifest)
    redirect "/kata/group/#{id}"
  end

  get '/save_individual' do
    id = create_kata(starter_manifest)
    redirect "/kata/edit/#{id}"
  end

  private

  include CreateGroup
  include CreateKata

  def starter_manifest
    name = params['display_name']
    manifest = start_points.manifest(name)
    manifest['created'] = time.now
    manifest['version'] = 1
    manifest
  end

  #- - - - - - - - - - - - - - - - - - - - - - -

  def start_points
    @externals.custom_start_points
  end

  def time
    @externals.time
  end

end
