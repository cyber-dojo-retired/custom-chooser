# frozen_string_literal: true
require_relative 'chooser.rb'
require_relative 'app_base'

class App < AppBase

  # - - - - - - - - - - - - - - - - - - - - - -
  # ctor

  def initialize(externals)
    super()
    @externals = externals
  end

  def target
    Chooser.new(@externals)
  end

  get_probe(:alive?) # curl/k8s
  get_probe(:ready?) # curl/k8s
  get_json(:sha)     # identity

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
    respond_to do |format|
      format.html {
        id = target.create_custom_group(**params_args)
        redirect group_path(id)
      }
    end
  end

  post '/create_group', provides:[:json] do
    respond_to do |format|
      format.json {
        id = target.create_custom_group(**json_args)
        new_api = { create_group:id }
        backwards_compatible = { id:id }
        json new_api.merge(backwards_compatible)
      }
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
    respond_to do |format|
      format.html {
        id = target.create_custom_kata(**params_args)
        redirect kata_path(id)
      }
    end
  end

  post '/create_kata', provides:[:json] do
    respond_to do |format|
      format.json {
        id = target.create_custom_kata(**json_args)
        new_api = { create_kata:id }
        backwards_compatible = { id:id }
        json new_api.merge(backwards_compatible)
      }
    end
  end

  def kata_path(id)
    "/kata/edit/#{id}"
  end

end
