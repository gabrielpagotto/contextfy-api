require "test_helper"

class GenderTest < ActiveSupport::TestCase
  setup do
    @existing_user = users(:one)
  end

  test "should create a valid gender" do
    gender = Gender.new(sptf_gender_id: "spotify_12345", user: @existing_user)
    assert gender.save, "Failed to save a valid gender"
  end

  test "should not save gender without sptf_gender_id or user_id" do
    gender = Gender.new(user: @existing_user)
    assert_not gender.save, "Saved the gender without a sptf_gender_id"
    gender = Gender.new(sptf_gender_id: "spotify_12345")
    assert_not gender.save, "Saved the gender without a user_id"
  end

  test "should allow setting deleted_at" do
    gender = Gender.create(sptf_gender_id: "spotify_12345", user: @existing_user)
    gender.update(deleted_at: Time.now)
    assert_not_nil gender.deleted_at, "deleted_at not set correctly"
  end

  test "should perform soft delete" do
    gender = Gender.create(sptf_gender_id: "spotify_12345", user: @existing_user)
    gender.update(deleted_at: Time.now)
    assert_not_nil gender.deleted_at, "Gender was not soft deleted"
  end
end
