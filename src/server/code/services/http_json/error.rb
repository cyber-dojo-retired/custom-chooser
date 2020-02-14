# frozen_string_literal: true

module HttpJson

  class Error < RuntimeError
    def initialize(message)
      super
    end
  end

end
