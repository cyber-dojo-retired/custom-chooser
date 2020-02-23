# frozen_string_literal: true
require_relative 'externals'
require_relative 'json_app_base'

class App < JsonAppBase

  # - - - - - - - - - - - - - - - - - - - - - -
  # ctor

  def initialize(app=nil, externals=Externals.new)
    super(app)
    @externals = externals
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
  # identity

  get '/sha', provides:[:json] do
    respond_to do |format|
      format.json { json sha: ENV['SHA'] }
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # html page

  get '/index', provides:[:html] do
    @display_names = custom_start_points.display_names
    if params['for'] === 'kata'
      @possessive = 'my'
      @create_url = '/create_kata'
    else
      @possessive = 'our'
      @create_url = '/create_group'
    end
    erb :index
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # ajax calls

  post '/create_group', provides:[:json] do
    id = creator.create_custom_group(display_name)
    respond_to do |format|
      format.json { json id:id, route:"/kata/group/#{id}" } # [8]
    end
  end

  post '/create_kata', provides:[:json] do
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
