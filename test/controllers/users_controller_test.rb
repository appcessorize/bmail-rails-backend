require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # --- GET /me tests ---

  test "me returns current user info" do
    get "/me", headers: auth_headers_for(:matt)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "matt", json["username"]
    assert json.key?("shame_active")
    assert json.key?("page_slug")
    assert json.key?("page_deleted")
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

  # --- Delete page tests ---

  test "delete page clears page data" do
    delete "/my_page", headers: auth_headers_for(:matt)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "Page deleted", json["message"]

    user = users(:matt).reload
    assert_nil user.page_slug
    assert_equal false, user.shame_active
    assert_equal true, user.page_deleted
    assert_equal false, user.image_public
  end

  test "delete page without auth returns 401" do
    delete "/my_page"
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
