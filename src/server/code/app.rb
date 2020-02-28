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
  # group

  get '/index_group', provides:[:html] do
    respond_to do |format|
      format.html do
        @display_names = target.display_names
        @possessive = 'our'
        @create_url = '/custom-chooser/create_group'
        erb :index
      end
    end
  end

  get '/create_group', provides:[:html] do
    id = target.create_custom_group(**params_args)
    respond_to do |format|
      format.html { redirect group_path(id) }
    end
  end

  post '/create_group', provides:[:json] do
    id = target.create_custom_group(**json_args)
    respond_to do |format|
      format.json { json id:id, route:group_path(id) }
    end
  end

  def group_path(id)
    "/kata/group/#{id}"
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # kata

  get '/index_kata', provides:[:html] do
    respond_to do |format|
      format.html do
        @display_names = target.display_names
        @possessive = 'my'
        @create_url = '/custom-chooser/create_kata'
        erb :index
      end
    end
  end

  get '/create_kata', provides:[:html] do
    id = target.create_custom_kata(**params_args)
    respond_to do |format|
      format.html { redirect kata_path(id) }
    end
  end

  post '/create_kata', provides:[:json] do
    id = target.create_custom_kata(**json_args)
    respond_to do |format|
      format.json { json id:id, route:kata_path(id) }
    end
  end

  def kata_path(id)
    "/kata/edit/#{id}"
  end

end
