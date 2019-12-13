# frozen_string_literal: true

require_relative 'http_json/service'
require_relative 'http_json/error'

class Creator

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

  def create_group(manifest)
    @http.post(__method__, { manifest:manifest })
  end

  def create_kata(manifest)
    @http.post(__method__, { manifest:manifest })
  end

end
