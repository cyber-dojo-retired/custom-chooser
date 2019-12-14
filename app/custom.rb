# frozen_string_literal: true

require 'sinatra/base'
require 'sprockets'
#require 'uglifier'

class Custom < Sinatra::Base

  set :port, ENV['PORT']
  set :environment, Sprockets::Environment.new
  environment.append_path('assets/stylesheets')
  environment.append_path('assets/javascripts')
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
    { "ready?": start_points.ready? && creator.ready? }.to_json
  end

  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  get '/index' do
    @display_names = start_points.display_names
    @for = params['for']
    erb :index
  end

  post '/create_group' do
    manifest = start_points.manifest(display_name)
    id = creator.create_group(manifest)
    redirect "/kata/group/#{id}"
  end

  post '/create_kata' do
    manifest = start_points.manifest(display_name)
    id = creator.create_kata(manifest)
    redirect "/kata/edit/#{id}"
  end

  private

  def display_name
    params['display_name']
  end

  def creator
    @externals.creator
  end

  def start_points
    @externals.custom_start_points
  end

end
