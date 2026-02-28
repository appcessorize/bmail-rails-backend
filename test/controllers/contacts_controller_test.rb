require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  # --- Contact form tests ---

  test "GET /contact renders form" do
    get "/contact"
    assert_response :ok
    assert_includes response.body, "contact-form"
  end

  test "POST /contact with valid params creates contact" do
    assert_difference("Contact.count", 1) do
      post "/contact", params: { email: "test@example.com", message: "This is a valid test message for the contact form." }
    end
    assert_response :ok
    assert_includes response.body, "Thank You"
  end

  test "POST /contact with invalid email shows error" do
    post "/contact", params: { email: "", message: "This is a valid message." }
    assert_response :unprocessable_entity
    assert_includes response.body, "error-box"
  end

  test "POST /contact with short message shows error" do
    post "/contact", params: { email: "test@example.com", message: "short" }
    assert_response :unprocessable_entity
    assert_includes response.body, "error-box"
  end

  # --- Admin endpoint tests ---

  test "admin contacts without token returns 401" do
    get "/admin/contacts"
    assert_response :unauthorized
  end

  test "admin contacts with wrong token returns 401" do
    get "/admin/contacts", headers: { "X-Admin-Token" => "wrong-token" }
    assert_response :unauthorized
  end

  test "admin contacts with valid token returns contacts" do
    ENV["ADMIN_TOKEN"] = "test-admin-secret"
    get "/admin/contacts", headers: { "X-Admin-Token" => "test-admin-secret" }
    assert_response :ok
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  ensure
    ENV.delete("ADMIN_TOKEN")
  end

  test "admin contacts returns 401 when ADMIN_TOKEN env var is missing" do
    ENV.delete("ADMIN_TOKEN")
    get "/admin/contacts", headers: { "X-Admin-Token" => "anything" }
    assert_response :unauthorized
  end

  # --- XSS prevention tests ---

  test "error messages are HTML-escaped in form" do
    post "/contact", params: { email: "", message: "Valid message with enough length here." }
    assert_response :unprocessable_entity
    # Error messages should contain escaped HTML entities, not raw tags
    # The error-box div should contain properly escaped validation messages
    assert_includes response.body, "error-box"
    assert_includes response.body, "Email can&#39;t be blank"
  end
end
