# frozen_string_literal: true
require_relative 'custom_test_base'
require 'capybara/minitest'

# https://medium.com/@jfroom/docker-compose-capybara-selenium-standalone-for-dev-ci-6514bf16d77b
# https://ahmetkizilay.com/2016/02/07/dockerized-selenium-testing-with-capybara.html
# https://www.alfredo.motta.name/dockerized-rails-capybara-tests-on-top-of-selenium/

class CapybaraTest < CustomTestBase
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
      browser: :remote,
      url: "http://selenium:4444/wd/hub",
      desired_capabilities: :firefox
    )
  end

  def setup
    Capybara.app_host = "http://custom-chooser:4536"
    Capybara.javascript_driver = :selenium
    Capybara.current_driver    = :selenium
    Capybara.run_server = false
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.app_host = nil
  end

  def self.id58_prefix
    'xRa'
  end

  # - - - - - - - - - - - - - - - - -

  test 'e5D',
  %w( index and selection ) do
    visit('/index')
    find('div.display-name', text: 'Java Countdown, Round 1').click
    find('#ok').click
    p current_path
    #expect(page).to have_content('/kata')
    #p body
    #p page.driver.status_code
    #p page.driver.browser.last_response['Location']
  end

end
