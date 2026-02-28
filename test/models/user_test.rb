require "test_helper"

class UserTest < ActiveSupport::TestCase
  # --- Validation tests ---

  test "valid user with all required fields" do
    user = User.new(username: "newuser", email: "new@example.com", password: "GoodPass1", password_confirmation: "GoodPass1")
    assert user.valid?, user.errors.full_messages.join(", ")
  end

  test "requires username" do
    user = User.new(username: nil, email: "test@example.com", password: "GoodPass1")
    assert_not user.valid?
    assert_includes user.errors[:username], "can't be blank"
  end

  test "requires unique username" do
    user = User.new(username: users(:matt).username, email: "unique@example.com", password: "GoodPass1")
    assert_not user.valid?
    assert_includes user.errors[:username], "has already been taken"
  end

  test "requires unique email" do
    user = User.new(username: "unique_user", email: users(:matt).email, password: "GoodPass1")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "password minimum length is 8" do
    user = User.new(username: "short_pw", email: "short@example.com", password: "Short1", password_confirmation: "Short1")
    assert_not user.valid?
    assert user.errors[:password].any? { |e| e.include?("too short") }
  end

  test "password requires uppercase letter" do
    user = User.new(username: "nouppercase", email: "noupper@example.com", password: "lowercase1", password_confirmation: "lowercase1")
    assert_not user.valid?
    assert user.errors[:password].any? { |e| e.include?("uppercase") }
  end

  test "password requires lowercase letter" do
    user = User.new(username: "nolowercase", email: "nolower@example.com", password: "UPPERCASE1", password_confirmation: "UPPERCASE1")
    assert_not user.valid?
    assert user.errors[:password].any? { |e| e.include?("lowercase") }
  end

  test "password requires digit" do
    user = User.new(username: "nodigit", email: "nodigit@example.com", password: "NoDigitHere", password_confirmation: "NoDigitHere")
    assert_not user.valid?
    assert user.errors[:password].any? { |e| e.include?("digit") }
  end

  test "complex password passes validation" do
    user = User.new(username: "goodpw", email: "good@example.com", password: "GoodPass1", password_confirmation: "GoodPass1")
    assert user.valid?, user.errors.full_messages.join(", ")
  end

  test "apple user skips password validation" do
    user = User.new(username: "appleuser2", email: "apple2@example.com", apple_user_id: "unique_apple_id_123")
    assert user.valid?, user.errors.full_messages.join(", ")
  end

  # --- Token tests ---

  test "generate_auth_token creates token and digest" do
    user = User.new(username: "tokentest", email: "token@example.com", password: "GoodPass1", password_confirmation: "GoodPass1")
    user.generate_auth_token
    assert user.auth_token.present?
    assert user.token_digest.present?
    assert_equal Digest::SHA256.hexdigest(user.auth_token), user.token_digest
  end

  test "find_by_valid_token returns user for valid token" do
    user = users(:matt)
    found = User.find_by_valid_token("test_token_matt")
    assert_equal user, found
  end

  test "find_by_valid_token returns nil for expired token" do
    found = User.find_by_valid_token("test_token_expired")
    assert_nil found
  end

  test "find_by_valid_token returns nil for blank token" do
    assert_nil User.find_by_valid_token("")
    assert_nil User.find_by_valid_token(nil)
  end

  # --- Account lockout tests ---

  test "locked? returns false for unlocked user" do
    assert_not users(:matt).locked?
  end

  test "locked? returns true for locked user" do
    assert users(:locked_user).locked?
  end

  test "record_failed_login increments attempts" do
    user = users(:matt)
    assert_equal 0, user.failed_login_attempts
    user.record_failed_login!
    assert_equal 1, user.reload.failed_login_attempts
  end

  test "record_failed_login locks after MAX_FAILED_ATTEMPTS" do
    user = users(:matt)
    User::MAX_FAILED_ATTEMPTS.times { user.record_failed_login! }
    assert user.reload.locked?
  end

  test "reset_failed_logins clears attempts and lockout" do
    user = users(:locked_user)
    user.reset_failed_logins!
    assert_equal 0, user.reload.failed_login_attempts
    assert_nil user.locked_until
  end

  # --- Shame tests ---

  test "activate_shame sets shame_active" do
    user = users(:matt)
    user.activate_shame!
    assert user.reload.shame_active
    assert user.shame_activated_at.present?
  end

  test "deactivate_shame clears shame" do
    user = users(:shamed_user)
    user.deactivate_shame!
    assert_not user.reload.shame_active
    assert_nil user.shame_activated_at
  end

  # --- Page slug tests ---

  test "generates page_slug on create" do
    user = User.create!(username: "slugtest", email: "slug@example.com", password: "GoodPass1", password_confirmation: "GoodPass1")
    assert user.page_slug.present?
    assert_equal 12, user.page_slug.length
  end

  test "does not overwrite existing page_slug" do
    user = users(:matt)
    original_slug = user.page_slug
    user.generate_page_slug
    assert_equal original_slug, user.page_slug
  end
end
