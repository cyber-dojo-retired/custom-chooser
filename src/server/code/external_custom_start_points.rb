# frozen_string_literal: true
require_relative 'http_json_hash/service'

class ExternalCustomStartPoints

  def initialize(http)
    @http = HttpJsonHash::service(self.class.name, http, 'custom-start-points', 4526)
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
