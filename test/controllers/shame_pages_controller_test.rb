require "test_helper"

class ShamePagesControllerTest < ActionDispatch::IntegrationTest
  test "shame page renders for valid slug" do
    get "/p/abc123def456"
    assert_response :ok
  end

  test "shame page returns 404 for invalid slug" do
    get "/p/nonexistent999"
    assert_response :not_found
  end

  test "report content with valid params creates report" do
    assert_difference("Report.count", 1) do
      post "/p/abc123def456/report", params: { reason: "inappropriate", details: "Offensive content" }
    end
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Report submitted. Thank you.", json["message"]
  end

  test "report content with invalid reason fails" do
    post "/p/abc123def456/report", params: { reason: "bad_reason" }
    assert_response :unprocessable_entity
  end

  test "report content without reason fails" do
    post "/p/abc123def456/report", params: { reason: "" }
    assert_response :unprocessable_entity
  end

  test "admin reports index requires auth" do
    get "/admin/reports"
    assert_response :unauthorized
  end

  test "admin reports index with valid token returns reports" do
    ENV["ADMIN_TOKEN"] = "test-admin-token"
    Report.create!(page_slug: "abc123", reason: "inappropriate")

    get "/admin/reports", headers: { "X-Admin-Token" => "test-admin-token" }
    assert_response :ok
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    assert json.length >= 1
  ensure
    ENV.delete("ADMIN_TOKEN")
  end
end
