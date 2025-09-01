ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "bcrypt"
require "selenium-webdriver"
require "capybara/rails"
require "capybara/minitest"

module ActiveSupport
  class TestCase
    include Devise::Test::IntegrationHelpers
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    Capybara.default_max_wait_time = 30
    Capybara.server = :puma, { Silent: true }
  end
end
