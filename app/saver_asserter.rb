# frozen_string_literal: true

require_relative 'json_plain'
require_relative 'saver_service'

module SaverAsserter # mix-in

  def saver_assert_batch(*commands)
    results = saver.batch(commands)
    if results.any?(false)
      message = results.zip(commands).map do |result,(name,arg0)|
        saver_assert_info(name, arg0, result)
      end
      raise SaverService::Error, json_plain(message)
    end
    results
  end

  def saver_assert_info(name, arg0, result)
    { 'name' => name, 'arg[0]' => arg0, 'result' => result }
  end

  def saver
    @externals.saver
  end

end
