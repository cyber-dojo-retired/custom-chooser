require 'sinatra/base'
require 'sprockets'
require 'sass'

class Custom < Sinatra::Base

  set :environment, Sprockets::Environment.new
  environment.append_path "assets/stylesheets"
  environment.append_path "assets/javascripts"

  set :port, ENV['PORT']

  get "/ready?" do
    content_type :json
    { "ready?": true }.to_json
  end

  get "/assets/*" do
    env["PATH_INFO"].sub!("/assets", "")
    settings.environment.call(env)
  end

  get "/" do
    erb :index
  end

end
