require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # --- Login tests ---

  test "login with valid credentials returns token" do
    post "/login", params: { username: "matt", password: "Password1" }
    assert_response :ok
    json = JSON.parse(response.body)
    assert json["auth_token"].present?
    assert json["user"]["username"] == "matt"
  end

  test "login with wrong password returns 401" do
    post "/login", params: { username: "matt", password: "WrongPass1" }
    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "invalid_password", json["error"]
  end

  test "login with nonexistent user returns 404" do
    post "/login", params: { username: "nonexistent", password: "Password1" }
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "user_not_found", json["error"]
  end

  test "login to locked account returns 429" do
    post "/login", params: { username: "locked_user", password: "Password1" }
    assert_response :too_many_requests
    json = JSON.parse(response.body)
    assert_equal "account_locked", json["error"]
  end

  test "failed logins increment attempts" do
    user = users(:matt)
    assert_equal 0, user.failed_login_attempts

    post "/login", params: { username: "matt", password: "WrongPass1" }
    assert_response :unauthorized
    assert_equal 1, user.reload.failed_login_attempts
  end

  test "successful login resets failed attempts" do
    user = users(:matt)
    user.update!(failed_login_attempts: 3)

    post "/login", params: { username: "matt", password: "Password1" }
    assert_response :ok
    assert_equal 0, user.reload.failed_login_attempts
  end

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
