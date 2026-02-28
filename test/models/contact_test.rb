require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "valid contact" do
    contact = Contact.new(email: "valid@example.com", message: "This is a valid message that is long enough.")
    assert contact.valid?
  end

  test "requires email" do
    contact = Contact.new(email: nil, message: "Valid message content here.")
    assert_not contact.valid?
    assert_includes contact.errors[:email], "can't be blank"
  end

  test "requires valid email format" do
    contact = Contact.new(email: "not-an-email", message: "Valid message content here.")
    assert_not contact.valid?
    assert contact.errors[:email].any? { |e| e.include?("invalid") }
  end

  test "requires message" do
    contact = Contact.new(email: "valid@example.com", message: nil)
    assert_not contact.valid?
    assert_includes contact.errors[:message], "can't be blank"
  end

  test "message minimum length is 10" do
    contact = Contact.new(email: "valid@example.com", message: "short")
    assert_not contact.valid?
    assert contact.errors[:message].any? { |e| e.include?("too short") }
  end

  test "message maximum length is 5000" do
    contact = Contact.new(email: "valid@example.com", message: "a" * 5001)
    assert_not contact.valid?
    assert contact.errors[:message].any? { |e| e.include?("too long") }
  end

  test "unread scope" do
    assert Contact.unread.all? { |c| c.read == false }
  end

  test "recent scope orders by created_at desc" do
    contacts = Contact.recent.to_a
    assert_equal contacts, contacts.sort_by(&:created_at).reverse
  end
end
