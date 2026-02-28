ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end

module AuthTestHelper
  # Returns an Authorization header hash for the given fixture user
  def auth_headers_for(user_fixture_name)
    token = "test_token_#{user_fixture_name}"
    { "Authorization" => "Bearer #{token}" }
  end

  # Returns headers with an invalid token
  def invalid_auth_headers
    { "Authorization" => "Bearer invalid_token_xyz" }
  end
end

class ActionDispatch::IntegrationTest
  include AuthTestHelper
end
