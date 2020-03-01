# frozen_string_literal: true
require_relative 'custom_test_base'

class IndexTest < CustomTestBase

  def self.id58_prefix
    'a73'
  end

  # - - - - - - - - - - - - - - - - -

  test '18w',
  %w( index_group offers selection to create a group ) do
    get '/index_group'
    assert last_response.ok?
    html = last_response.body
    assert heading(html).include?('our'), html
    refute heading(html).include?('my'), html
    display_names.each do |display_name|
      expected = /<div class="display-name">\s*#{display_name}\s*<\/div>/
      assert html =~ expected, display_name
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '19w',
  %w( index_kata offers selection to create a kata ) do
    get '/index_kata'
    assert last_response.ok?
    html = last_response.body
    assert heading(html).include?('my'), html
    refute heading(html).include?('our'), html
    display_names.each do |display_name|
      expected = /<div class="display-name">\s*#{display_name}\s*<\/div>/
      assert html =~ expected, display_name
    end
  end

  private

  def display_names
    [
      'Java Countdown, Round 1',
      'Java Countdown, Round 2',
      'Java Countdown, Round 3'
    ]
  end

  def heading(html)
    # (.*?) for non-greedy match
    # /m for . matching newlines
    html.match(/<div id="heading">(.*?)<\/div>/m)[1]
  end

end
