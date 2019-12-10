require 'sinatra/base'
require 'sprockets'
require 'uglifier'

class Custom < Sinatra::Base

  set :port, ENV['PORT']
  set :environment, Sprockets::Environment.new
  environment.append_path "assets/stylesheets"
  environment.append_path "assets/javascripts"
  environment.js_compressor  = Uglifier.new(harmony: true)
  environment.css_compressor = :scss

  def initialize(app = nil, externals)
    super(app)
    @externals = externals
  end

  get "/sha" do
    #content_type :json
    { "sha": ENV['SHA'] }.to_json
  end

  get "/alive" do
    #content_type :json
    { "alive": true }.to_json
  end

  get "/ready" do
    #content_type :json
    { "ready": true }.to_json
  end

  get "/assets/*" do
    env["PATH_INFO"].sub!("/assets", "")
    settings.environment.call(env)
  end

  get "/" do
    erb :index
  end

end
