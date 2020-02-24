# frozen_string_literal: true
require_relative 'chooser.rb'
require_relative 'json_app_base'

class App < JsonAppBase

  # - - - - - - - - - - - - - - - - - - - - - -
  # ctor

  def initialize(externals)
    super()
    @externals = externals
  end

  def target
    Chooser.new(@externals)
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # html page

  get '/index', provides:[:html] do
    @display_names = target.display_names
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
    id = target.create_custom_group(**args)
    respond_to do |format|
      format.json { json id:id, route:"/kata/group/#{id}" }
    end
  end

  post '/create_kata', provides:[:json] do
    id = target.create_custom_kata(**args)
    respond_to do |format|
      format.json { json id:id, route:"/kata/edit/#{id}" }
    end
  end

end
