require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get "/"
    assert_response :ok
  end

  test "privacy page renders" do
    get "/privacy"
    assert_response :ok
  end

  test "terms page renders" do
    get "/terms"
    assert_response :ok
  end
end
