require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # --- Signup tests ---

  test "signup with valid params creates user" do
    assert_difference("User.count", 1) do
      post "/signup", params: { user: { username: "brand_new", email: "brandnew@example.com", password: "GoodPass1", password_confirmation: "GoodPass1" } }
    end
    assert_response :created
    json = JSON.parse(response.body)
    assert json["auth_token"].present?
    assert_equal "brand_new", json["user"]["username"]
  end

  test "signup with weak password fails" do
    post "/signup", params: { user: { username: "weakpw", email: "weak@example.com", password: "weakpass", password_confirmation: "weakpass" } }
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert json["errors"].any? { |e| e.include?("uppercase") || e.include?("digit") }
  end

  test "signup with short password fails" do
    post "/signup", params: { user: { username: "shortpw", email: "short@example.com", password: "Sh1", password_confirmation: "Sh1" } }
    assert_response :unprocessable_entity
  end

  test "signup with duplicate username fails" do
    post "/signup", params: { user: { username: "matt", email: "different@example.com", password: "GoodPass1", password_confirmation: "GoodPass1" } }
    assert_response :unprocessable_entity
  end

  # --- GET /me tests ---

  test "me returns current user info" do
    get "/me", headers: auth_headers_for(:matt)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "matt", json["username"]
    assert json.key?("shame_active")
    assert json.key?("page_slug")
  end

  test "me without auth returns 401" do
    get "/me"
    assert_response :unauthorized
  end

  test "me with expired token returns 401" do
    get "/me", headers: auth_headers_for(:expired)
    assert_response :unauthorized
  end

  # --- Shame deactivation tests ---

  test "deactivate shame clears shame status" do
    patch "/shame/deactivate", headers: auth_headers_for(:shamed)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal false, json["shame_active"]
  end

  test "deactivate shame without auth returns 401" do
    patch "/shame/deactivate"
    assert_response :unauthorized
  end

  # --- Account deletion tests ---

  test "delete account removes user" do
    assert_difference("User.count", -1) do
      delete "/delete_account", headers: auth_headers_for(:matt)
    end
    assert_response :ok
  end

  test "delete account without auth returns 401" do
    delete "/delete_account"
    assert_response :unauthorized
  end
end
