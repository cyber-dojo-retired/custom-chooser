# frozen_string_literal: true
require_relative 'http_json_hash/service'

class ExternalCustomStartPoints

  def initialize(http)
    @http = HttpJsonHash::service(self.class.name, http, 'custom-start-points', 4526)
  end

  def ready?
    @http.get(__method__, {})
  end

  def display_names
    @http.get(:names, {})
  end

end
