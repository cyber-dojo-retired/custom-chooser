# frozen_string_literal: true
require_relative 'custom_test_base'

class IndexTest < CustomTestBase

  def self.id58_prefix
    'a73'
  end

  # - - - - - - - - - - - - - - - - -

  test '18w',
  %w( index ) do
    get '/index'
    assert last_response.ok?    
    a_display_name = 'Java Countdown, Round 1'
    html = last_response.body
    expected = /<div class="display-name">\s*#{a_display_name}\s*<\/div>/
    assert html =~ expected, html
  end

  # - - - - - - - - - - - - - - - - -

  test '19w',
  %w( heading possessive is 'my' when 'for' param is 'kata') do
    get '/index', for:'kata'
    html = last_response.body
    assert heading(html).include?('my')
  end

  # - - - - - - - - - - - - - - - - -

  test '20w',
  %w( heading possessive is 'our' when 'for' param is 'group') do
    get '/index', for:'group'
    html = last_response.body
    assert heading(html).include?('our')
  end

  # - - - - - - - - - - - - - - - - -

  test '21w',
  %w( heading possessive is 'our' when 'for' param is unknown) do
    get '/index', for:'unknown'
    html = last_response.body
    assert heading(html).include?('our')
  end

  private

  def heading(html)
    # (.*?) for non-greedy match
    # /m for . matching newlines
    html.match(/<div id="heading">(.*?)<\/div>/m)[1]
  end

end
