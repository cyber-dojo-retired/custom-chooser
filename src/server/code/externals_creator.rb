# frozen_string_literal: true
require_relative 'services/http_json/service'
require_relative 'services/http_json/error'

class ExternalsCreator

  class Error < HttpJson::Error
    def initialize(message)
      super
    end
  end

  def initialize(http)
    @http = HttpJson::service(http, 'creator', 4523, Error)
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

  def create_custom_group(display_name)
    @http.post(__method__, { display_name:display_name })
  end

  def create_custom_kata(display_name)
    @http.post(__method__, { display_name:display_name })
  end

end
