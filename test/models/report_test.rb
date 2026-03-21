require "test_helper"

class ReportTest < ActiveSupport::TestCase
  test "valid report" do
    report = Report.new(page_slug: "abc123", reason: "inappropriate", details: "Offensive photo")
    assert report.valid?
  end

  test "requires page_slug" do
    report = Report.new(page_slug: nil, reason: "inappropriate")
    assert_not report.valid?
    assert_includes report.errors[:page_slug], "can't be blank"
  end

  test "requires reason" do
    report = Report.new(page_slug: "abc123", reason: nil)
    assert_not report.valid?
    assert_includes report.errors[:reason], "can't be blank"
  end

  test "requires valid reason" do
    report = Report.new(page_slug: "abc123", reason: "invalid_reason")
    assert_not report.valid?
    assert_includes report.errors[:reason], "is not included in the list"
  end

  test "accepts all valid reasons" do
    Report::VALID_REASONS.each do |reason|
      report = Report.new(page_slug: "abc123", reason: reason)
      assert report.valid?, "Expected '#{reason}' to be valid"
    end
  end

  test "limits details length" do
    report = Report.new(page_slug: "abc123", reason: "other", details: "x" * 2001)
    assert_not report.valid?
  end
end
