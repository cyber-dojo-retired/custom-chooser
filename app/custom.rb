require 'sinatra/base'
require 'sprockets'
require 'uglifier'

class Custom < Sinatra::Base

  set :port, ENV['PORT']
  set :environment, Sprockets::Environment.new
  environment.append_path "assets/stylesheets"
  environment.append_path "assets/javascripts"
  #environment.js_compressor  = Uglifier.new(harmony: true)
  environment.css_compressor = :scss

  after do
    response["Connection"] = "Close"    
  end

  def initialize(app = nil, externals)
    super(app)
    @externals = externals
  end

  get "/sha" do
    content_type :json
    { "sha": ENV['SHA'] }.to_json
  end

  get "/alive" do
    content_type :json
    { "alive?": true }.to_json
  end

  get "/ready" do
    content_type :json
    { "ready?": start_points.ready? }.to_json
  end

  get "/assets/*" do
    env["PATH_INFO"].sub!("/assets", "")
    settings.environment.call(env)
  end

  get "/show" do
    @display_names = start_points.names
    @custom_index = random_index(@display_names)
    @from = params['from']
    erb :show
  end

  private

  def start_points
    @externals.custom_start_points
  end

  def random_index(names)
    rand(0...names.size)
  end

end
