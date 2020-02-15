# frozen_string_literal: true
require_relative 'externals'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sprockets'

class Custom < Sinatra::Base
  register Sinatra::Contrib

  set :port, ENV['PORT']
  set :environment, Sprockets::Environment.new
  environment.append_path('code/assets/stylesheets')
  environment.append_path('code/assets/javascripts')
  #environment.css_compressor = :scss

  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # ctor

  def initialize(app=nil, externals=Externals.new)
    super(app)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # identity

  get '/sha' do
    content_type :json
    { 'sha': ENV['SHA'] }.to_json
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # k8s/curl probing

  get '/alive' do
    content_type :json
    { 'alive?': true }.to_json
  end

  get '/ready' do
    content_type :json
    { 'ready?': custom_start_points.ready? && creator.ready? }.to_json
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # main routes

  get '/index' do
    @display_names = custom_start_points.display_names
    @for = params['for']
    erb :index
  end

  post '/create_group', :provides => [:html, :json] do
    manifest = custom_start_points.manifest(display_name)
    id = creator.create_group(manifest)
    respond_to do |format|
      format.html { redirect "/kata/group/#{id}" }
      format.json { { id:id }.to_json }
    end
  end

  post '/create_kata', :provides => [:html, :json] do
    manifest = custom_start_points.manifest(display_name)
    id = creator.create_kata(manifest)
    respond_to do |format|
      format.html { redirect "/kata/edit/#{id}" }
      format.json { { id:id }.to_json }
    end
  end

  private

  def display_name
    params['display_name']
  end

  def creator
    @externals.creator
  end

  def custom_start_points
    @externals.custom_start_points
  end

end
