# frozen_string_literal: true
require_relative 'silently'
require 'sinatra/base'
silently { require 'sinatra/contrib' } # N x "warning: method redefined"
require 'sprockets'

class JsonAppBase < Sinatra::Base

  def initialize
    super(nil)
  end

  silently { register Sinatra::Contrib }
  set :port, ENV['PORT']

  # - - - - - - - - - - - - - - - - - - - - - -
  set :show_exceptions, false

  error do
    error = $!
    puts "(500):#{error.message}:"
    status(500)
    #content_type('application/json')
    body(error.message)
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # stylesheets and javascript

  set :environment, Sprockets::Environment.new
  # append asset paths
  environment.append_path('code/assets/stylesheets')
  environment.append_path('code/assets/javascripts')
  # compress assets
  #environment.js_compressor  = :uglify
  #environment.css_compressor = :scss

  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.get_json(name)
    get "/#{name}", provides:[:json] do
      respond_to do |format|
        format.json {
          result = instance_eval {
            target.public_send(name, **args)
          }
          json({ name => result })
        }
      end
    end
  end

  get_json(:sha) # identity

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.probe(name)
    get "/#{name}" do
      result = instance_eval { target.public_send(name) }
      json({ name => result })
    end
  end

  probe(:alive?) # curl/k8s
  probe(:ready?) # curl/k8s

  # - - - - - - - - - - - - - - - - - - - - - -

  def args
    payload = json_hash_parse(request.body.read)
    Hash[payload.map{ |key,value| [key.to_sym, value] }]
  end

  private

  def json_hash_parse(body)
    json = (body === '') ? {} : JSON.parse!(body)
    unless json.instance_of?(Hash)
      fail 'body is not JSON Hash'
    end
    json
  rescue JSON::ParserError
    fail 'body is not JSON'
  end

end
