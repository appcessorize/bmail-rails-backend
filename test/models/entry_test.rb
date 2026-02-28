require "test_helper"

class EntryTest < ActiveSupport::TestCase
  test "valid entry with title and body" do
    entry = Entry.new(title: "Test", body: "Test body", user: users(:matt))
    assert entry.valid?
  end

  test "requires title" do
    entry = Entry.new(title: nil, body: "Has body", user: users(:matt))
    assert_not entry.valid?
    assert_includes entry.errors[:title], "can't be blank"
  end

  test "requires body" do
    entry = Entry.new(title: "Has title", body: nil, user: users(:matt))
    assert_not entry.valid?
    assert_includes entry.errors[:body], "can't be blank"
  end

  test "belongs to user" do
    entry = entries(:matt_entry)
    assert_equal users(:matt), entry.user
  end
end
