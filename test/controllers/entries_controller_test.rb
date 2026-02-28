require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  # --- Auth tests ---

  test "index without auth returns 401" do
    get "/entries"
    assert_response :unauthorized
  end

  test "create without auth returns 401" do
    post "/entries", params: { entry: { title: "Test", body: "Body" } }
    assert_response :unauthorized
  end

  # --- CRUD tests ---

  test "index returns user entries" do
    get "/entries", headers: auth_headers_for(:matt)
    assert_response :ok
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end

  test "create entry with valid params" do
    assert_difference("Entry.count", 1) do
      post "/entries", params: { entry: { title: "New Entry", body: "New body content" } }, headers: auth_headers_for(:matt)
    end
    assert_response :created
  end

  test "create entry without title fails" do
    post "/entries", params: { entry: { title: "", body: "Has body" } }, headers: auth_headers_for(:matt)
    assert_response :unprocessable_entity
  end

  test "create entry without body fails" do
    post "/entries", params: { entry: { title: "Has title", body: "" } }, headers: auth_headers_for(:matt)
    assert_response :unprocessable_entity
  end

  test "show entry belonging to user" do
    entry = entries(:matt_entry)
    get "/entries/#{entry.id}", headers: auth_headers_for(:matt)
    assert_response :ok
  end

  test "show entry belonging to other user returns 404" do
    entry = entries(:jane_entry)
    get "/entries/#{entry.id}", headers: auth_headers_for(:matt)
    assert_response :not_found
  end

  test "update entry" do
    entry = entries(:matt_entry)
    patch "/entries/#{entry.id}", params: { entry: { title: "Updated Title" } }, headers: auth_headers_for(:matt)
    assert_response :ok
    assert_equal "Updated Title", entry.reload.title
  end

  test "destroy entry" do
    entry = entries(:matt_entry)
    assert_difference("Entry.count", -1) do
      delete "/entries/#{entry.id}", headers: auth_headers_for(:matt)
    end
    assert_response :no_content
  end

  test "cannot destroy other user entry" do
    entry = entries(:jane_entry)
    delete "/entries/#{entry.id}", headers: auth_headers_for(:matt)
    assert_response :not_found
  end
end
