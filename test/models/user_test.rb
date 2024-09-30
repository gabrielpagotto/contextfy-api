require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should create a valid user" do
    user = User.new(sptf_user_id: "spotify_12345")
    assert user.save, "Failed to save a valid user"
  end

  test "should not save user without sptf_user_id" do
    user = User.new
    assert_not user.save, "Saved the user without a sptf_user_id"
  end

  test "should allow setting deleted_at" do
    user = User.create(sptf_user_id: "spotify_12345")
    user.update(deleted_at: Time.now)
    assert_not_nil user.deleted_at, "deleted_at not set correctly"
  end

  test "should perform soft delete" do
    user = User.create(sptf_user_id: "spotify_12345")
    user.update(deleted_at: Time.now)
    assert_not_nil user.deleted_at, "User was not soft deleted"
  end
end
