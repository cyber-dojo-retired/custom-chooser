# frozen_string_literal: true
require_relative 'custom_test_base'

class IndexGroupTest < CustomTestBase

  def self.id58_prefix
    'xRa'
  end

  # - - - - - - - - - - - - - - - - -

  test 'e5D',
  %w( index_group and selection ) do
    visit('/index_group')
    find('div.display-name', text: 'Java Countdown, Round 1').click
    find('#ok').click
    # TODO: wait for browser to handle redirection?
    p current_path # /custom-chooser/create_group
  end

end
