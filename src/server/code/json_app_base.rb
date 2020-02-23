# frozen_string_literal: true
require_relative 'silent_warnings'
require 'sinatra/base'
require_silent 'sinatra/contrib' # N x "warning: method redefined"
require 'sprockets'

class JsonAppBase < Sinatra::Base

  silent_warnings { register Sinatra::Contrib }
  set :port, ENV['PORT']
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

  # get assets
  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end

end
