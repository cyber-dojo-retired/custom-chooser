# frozen_string_literal: true
require_relative 'app_base'
require_relative 'chooser.rb'
require_relative 'escape_html_helper'
require_relative 'selected_helper'

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
        set_view_data('group_create')
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

  # - - - - - - - - - - - - - - - - - - - - - -
  # kata

  get '/kata_choose', provides:[:html] do
    respond_to do |format|
      format.html do
        set_view_data('kata_create')
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

  private

  def set_view_data(next_page)
    manifests = target.manifests
    @display_names = manifests.keys.sort
    @display_contents = []
    @display_names.each do |name|
      visible_files = manifests[name]['visible_files']
      filename = selected(visible_files)
      content = visible_files[filename]['content']
      @display_contents << content
    end
    @create_url = "/custom-chooser/#{next_page}"
  end

  include EscapeHtmlHelper
  include SelectedHelper

end
