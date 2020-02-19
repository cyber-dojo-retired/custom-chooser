# frozen_string_literal: true
require_relative 'externals'
require_relative 'silent_warnings'
require_silent 'sinatra/contrib' # N x "warning: method redefined"
require 'sinatra/base'
require 'sprockets'

class Custom < Sinatra::Base

  silent_warnings { register Sinatra::Contrib }
  set :port, ENV['PORT']
  set :show_exceptions, false

  # TODO: 1 add error handler (see creator)
  # TODO: 2 create super thin separate App class (see creator)
  # TODO: 3 ensure Custom.new object is created for each incoming request
  #         but as @custom in tests so externals can be stubbed
  # TODO: 4 add **splat handling
  # TODO: 5 add button disable/enable wrapping around ajax call
  # TODO: 6 check error handling in JS when creator fails
  # TODO: 7 check error handling in JS when saver fails. creator needs to pass saver error 'through'
  # TODO: 8 should create_group should return id:id and ALSO create_group:id to follow the pattern
  #         of main path returning info against a key that matches the method name
  # TODO: 8 same for create_kata()

  error do
    error = $!
    puts "(500):#{error.message}:"
    status(500)
    #content_type('application/json')
    body(error.message)
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # ctor

  def initialize(app=nil, externals=Externals.new)
    super(app)
    @externals = externals
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # identity

  get '/sha', provides:[:json] do
    respond_to do |format|
      format.json { json sha: ENV['SHA'] }
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # k8s/curl probing

  get '/alive?', provides:[:json] do
    respond_to do |format|
      format.json { json alive?: true }
    end
  end

  get '/ready?', provides:[:json] do
    respond_to do |format|
      format.json { json ready?: custom_start_points.ready? && creator.ready? }
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # html page

  get '/index', provides:[:html] do
    @display_names = custom_start_points.display_names
    if params['for'] === 'group'
      @possessive = 'our'
      @create_url = '/create_group'
    else
      @possessive = 'my'
      @create_url = '/create_kata'
    end
    erb :index
  end

  set :environment, Sprockets::Environment.new
  environment.append_path('code/assets/stylesheets')
  environment.append_path('code/assets/javascripts')
  #environment.css_compressor = :scss

  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # ajax calls

  post '/create_group', provides:[:html, :json] do
    id = creator.create_custom_group(display_name)
    respond_to do |format|
      format.json { json id:id, route:"/kata/group/#{id}" } # [8]
    end
  end

  post '/create_kata', provides:[:html, :json] do
    id = creator.create_custom_kata(display_name)
    respond_to do |format|
      format.json { json id: id, route:"/kata/edit/#{id}" } # [8]
    end
  end

  private

  def display_name
    payload['display_name']
  end

  def payload
    if request.content_type === 'application/json' # DROP. No non-json requests anymore
      json_hash_parse(request.body.read)
    else
      params
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def json_hash_parse(body)
    json = (body === '') ? {} : JSON.parse!(body)
    unless json.instance_of?(Hash)
      fail 'body is not JSON Hash'
    end
    json
  rescue JSON::ParserError
    fail 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def creator
    @externals.creator
  end

  def custom_start_points
    @externals.custom_start_points
  end

end
