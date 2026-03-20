require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # --- Logout tests ---

  test "logout invalidates token" do
    delete "/logout", headers: auth_headers_for(:matt)
    assert_response :no_content

    # Token should now be invalid
    get "/me", headers: auth_headers_for(:matt)
    assert_response :unauthorized
  end

  test "logout without auth returns 401" do
    delete "/logout"
    assert_response :unauthorized
  end
end
