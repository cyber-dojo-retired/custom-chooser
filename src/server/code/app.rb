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

  probe_get(:alive?) # curl/k8s
  probe_get(:ready?) # curl/k8s
  probe_get(:sha)    # identity

  # - - - - - - - - - - - - - - - - - - - - - -
  # group

  get '/group_choose', provides:[:html] do
    respond_to do |format|
      format.html do
        @display_names = target.display_names
        @create_url = '/custom-chooser/group_create'
        erb :'group/choose'
      end
    end
  end

  get '/group_create', provides:[:html] do
    respond_to do |format|
      format.html {
        id = target.group_create_custom(**params_args)
        redirect "/kata/group/#{id}"
      }
    end
  end

  post '/group_create', provides:[:json] do
    respond_to do |format|
      format.json {
        id = target.group_create_custom(**json_args)
        json({ group_create:id })
      }
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -
  # kata

  get '/kata_choose', provides:[:html] do
    respond_to do |format|
      format.html do
        @display_names = target.display_names
        @create_url = '/custom-chooser/kata_create'
        erb :'kata/choose'
      end
    end
  end

  get '/kata_create', provides:[:html] do
    respond_to do |format|
      format.html {
        id = target.kata_create_custom(**params_args)
        redirect "/kata/edit/#{id}"
      }
    end
  end

  post '/kata_create', provides:[:json] do
    respond_to do |format|
      format.json {
        id = target.kata_create_custom(**json_args)
        json({ kata_create:id })
      }
    end
  end

end
