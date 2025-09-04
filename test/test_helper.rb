ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "selenium-webdriver"
require "capybara/rails"
require "capybara/minitest"
require "webmock/minitest"

class ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  WebMock.disable_net_connect!(allow_localhost: true)
  Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  Capybara.default_max_wait_time = 30
  Capybara.server = :puma, { Silent: true }
end

# ✅ Add Warden helpers globally
include Warden::Test::Helpers
Warden.test_mode!

# ✅ Reset Warden after the test suite finishes
Minitest.after_run do
  Warden.test_reset!
end
