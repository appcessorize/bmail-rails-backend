require "test_helper"

class FocusSessionTest < ActiveSupport::TestCase
  test "valid focus session" do
    session = FocusSession.new(user: users(:matt), duration_minutes: 25, started_at: Time.current, status: "active")
    assert session.valid?
  end

  test "requires duration_minutes" do
    session = FocusSession.new(user: users(:matt), duration_minutes: nil, started_at: Time.current, status: "active")
    assert_not session.valid?
  end

  test "duration_minutes must be positive" do
    session = FocusSession.new(user: users(:matt), duration_minutes: 0, started_at: Time.current, status: "active")
    assert_not session.valid?

    session.duration_minutes = -5
    assert_not session.valid?
  end

  test "duration_minutes maximum is 480" do
    session = FocusSession.new(user: users(:matt), duration_minutes: 481, started_at: Time.current, status: "active")
    assert_not session.valid?

    session.duration_minutes = 480
    assert session.valid?
  end

  test "requires started_at" do
    session = FocusSession.new(user: users(:matt), duration_minutes: 25, started_at: nil, status: "active")
    assert_not session.valid?
  end

  test "status must be valid" do
    session = FocusSession.new(user: users(:matt), duration_minutes: 25, started_at: Time.current, status: "invalid")
    assert_not session.valid?
  end

  test "complete! sets status and ended_at" do
    session = focus_sessions(:active_session)
    session.complete!
    assert_equal "completed", session.status
    assert session.ended_at.present?
  end

  test "fail! sets status and activates shame" do
    session = focus_sessions(:active_session)
    session.fail!
    assert_equal "failed", session.reload.status
    assert session.ended_at.present?
    assert session.user.reload.shame_active
  end

  test "active? returns true for active session" do
    assert focus_sessions(:active_session).active?
  end

  test "active? returns false for completed session" do
    assert_not focus_sessions(:completed_session).active?
  end

  test "expired? returns true when past duration" do
    session = FocusSession.new(user: users(:matt), duration_minutes: 1, started_at: 5.minutes.ago, status: "active")
    assert session.expired?
  end

  test "expired? returns false when within duration" do
    session = FocusSession.new(user: users(:matt), duration_minutes: 60, started_at: 5.minutes.ago, status: "active")
    assert_not session.expired?
  end
end
