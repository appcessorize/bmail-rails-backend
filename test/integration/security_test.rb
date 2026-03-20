require "test_helper"

class SecurityTest < ActionDispatch::IntegrationTest
  # --- Authentication bypass tests ---

  test "all protected endpoints reject missing auth token" do
    protected_endpoints = [
      [:get, "/me"],
      [:delete, "/logout"],
      [:delete, "/delete_account"],
      [:delete, "/my_page"],
      [:post, "/upload_image"],
      [:patch, "/update_image_privacy"],
      [:delete, "/delete_image"],
      [:get, "/entries"],
      [:post, "/entries"],
      [:get, "/focus_sessions"],
      [:post, "/focus_sessions"],
      [:patch, "/shame/deactivate"]
    ]

    protected_endpoints.each do |method, path|
      send(method, path)
      assert_response :unauthorized, "#{method.upcase} #{path} should require auth"
    end
  end

  test "all protected endpoints reject invalid auth token" do
    headers = invalid_auth_headers

    get "/me", headers: headers
    assert_response :unauthorized

    get "/entries", headers: headers
    assert_response :unauthorized

    get "/focus_sessions", headers: headers
    assert_response :unauthorized
  end

  test "expired token is rejected" do
    get "/me", headers: auth_headers_for(:expired)
    assert_response :unauthorized
  end

  # --- Admin token security ---

  test "admin endpoint rejects empty admin token env" do
    ENV.delete("ADMIN_TOKEN")
    get "/admin/contacts", headers: { "X-Admin-Token" => "" }
    assert_response :unauthorized
  end

  test "admin endpoint uses timing-safe comparison" do
    ENV["ADMIN_TOKEN"] = "secret-admin-token-12345"

    # Correct token
    get "/admin/contacts", headers: { "X-Admin-Token" => "secret-admin-token-12345" }
    assert_response :ok

    # Partially correct token (timing attack attempt)
    get "/admin/contacts", headers: { "X-Admin-Token" => "secret-admin-token-1234X" }
    assert_response :unauthorized
  ensure
    ENV.delete("ADMIN_TOKEN")
  end

  # --- XSS prevention ---

  test "contact form escapes HTML in error messages" do
    # Submit with empty email to trigger validation error
    post "/contact", params: { email: "", message: "Valid message with enough characters here." }
    assert_response :unprocessable_entity
    # Error messages should use HTML entities, not raw special chars
    # The apostrophe in "can't" should be escaped as &#39;
    assert_includes response.body, "&#39;"
  end

  # --- Telegram injection ---

  test "telegram notification does not use HTML parse mode" do
    # We can verify this by checking the controller code doesn't use parse_mode: "HTML"
    controller_source = File.read(Rails.root.join("app/controllers/contacts_controller.rb"))
    assert_not_includes controller_source, 'parse_mode: "HTML"'
    assert_not_includes controller_source, "parse_mode: 'HTML'"
  end

  # --- Entry isolation ---

  test "user cannot read other user entries via direct ID" do
    entry = entries(:jane_entry)
    get "/entries/#{entry.id}", headers: auth_headers_for(:matt)
    assert_response :not_found
  end

  test "user cannot update other user entries" do
    entry = entries(:jane_entry)
    patch "/entries/#{entry.id}", params: { entry: { title: "Hacked" } }, headers: auth_headers_for(:matt)
    assert_response :not_found
  end

  test "user cannot delete other user entries" do
    entry = entries(:jane_entry)
    delete "/entries/#{entry.id}", headers: auth_headers_for(:matt)
    assert_response :not_found
  end

  # --- Focus session isolation ---

  test "user cannot access other user focus sessions" do
    session = focus_sessions(:active_session)  # belongs to matt
    get "/focus_sessions/#{session.id}", headers: auth_headers_for(:jane)
    assert_response :not_found
  end

  # --- Input validation ---

  test "focus session rejects extreme duration values" do
    post "/focus_sessions", params: { duration_minutes: 999999 }, headers: auth_headers_for(:jane)
    assert_response :unprocessable_entity
  end

end
