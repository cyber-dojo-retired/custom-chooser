require 'sinatra/base'

class Custom < Sinatra::Base

  set :port, 4536

  get "/ready?" do
    content_type :json
    { "ready?": true }.to_json
  end

  get "/" do
    "Hello World!"
  end

end
