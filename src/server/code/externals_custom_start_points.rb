# frozen_string_literal: true
require_relative 'services/http_json/service'
require_relative 'services/http_json/error'

class ExternalsCustomStartPoints

  class Error < HttpJson::Error
    def initialize(message)
      super
    end
  end

  def initialize(http)
    @http = HttpJson::service(http, 'custom-start-points', 4526, Error)
  end

  def alive?
    @http.get(__method__, {})
  end

  def ready?
    @http.get(__method__, {})
  end

  def sha
    @http.get(__method__, {})
  end

  def display_names
    @http.get(:names, {})
  end

  def manifests
    @http.get(__method__, {})
  end

  def manifest(display_name)
    @http.get(__method__, { name:display_name })
  end

end
