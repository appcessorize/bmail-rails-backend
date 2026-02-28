require "test_helper"

class FocusSessionsControllerTest < ActionDispatch::IntegrationTest
  # --- Auth tests ---

  test "index without auth returns 401" do
    get "/focus_sessions"
    assert_response :unauthorized
  end

  test "create without auth returns 401" do
    post "/focus_sessions", params: { duration_minutes: 25 }
    assert_response :unauthorized
  end

  # --- CRUD tests ---

  test "index returns user focus sessions" do
    get "/focus_sessions", headers: auth_headers_for(:matt)
    assert_response :ok
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end

  test "create focus session with valid duration" do
    # Cancel existing active sessions first by using a user without active sessions
    assert_difference("FocusSession.count", 1) do
      post "/focus_sessions", params: { duration_minutes: 25 }, headers: auth_headers_for(:jane)
    end
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal 25, json["duration_minutes"]
    assert_equal "active", json["status"]
  end

  test "create focus session with zero duration fails" do
    post "/focus_sessions", params: { duration_minutes: 0 }, headers: auth_headers_for(:jane)
    assert_response :unprocessable_entity
  end

  test "create focus session with negative duration fails" do
    post "/focus_sessions", params: { duration_minutes: -10 }, headers: auth_headers_for(:jane)
    assert_response :unprocessable_entity
  end

  test "create focus session exceeding max duration fails" do
    post "/focus_sessions", params: { duration_minutes: 481 }, headers: auth_headers_for(:jane)
    assert_response :unprocessable_entity
  end

  test "create focus session at max duration succeeds" do
    post "/focus_sessions", params: { duration_minutes: 480 }, headers: auth_headers_for(:jane)
    assert_response :created
  end

  test "complete active session" do
    session = focus_sessions(:active_session)
    patch "/focus_sessions/#{session.id}/complete", headers: auth_headers_for(:matt)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "completed", json["status"]
  end

  test "complete non-active session fails" do
    session = focus_sessions(:completed_session)
    patch "/focus_sessions/#{session.id}/complete", headers: auth_headers_for(:matt)
    assert_response :unprocessable_entity
  end

  test "fail active session activates shame" do
    session = focus_sessions(:active_session)
    patch "/focus_sessions/#{session.id}/fail", headers: auth_headers_for(:matt)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "failed", json["status"]
    assert json["shame_activated"]
  end

  test "get current session" do
    get "/focus_sessions/current", headers: auth_headers_for(:matt)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "active", json["status"]
  end

  test "get current session when none active" do
    get "/focus_sessions/current", headers: auth_headers_for(:jane)
    assert_response :ok
    json = JSON.parse(response.body)
    assert_nil json["active_session"]
  end

  test "cannot access other user sessions" do
    session = focus_sessions(:active_session)  # belongs to matt
    get "/focus_sessions/#{session.id}", headers: auth_headers_for(:jane)
    assert_response :not_found
  end
end
