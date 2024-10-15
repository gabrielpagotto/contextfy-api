require "test_helper"

class ContextTest < ActiveSupport::TestCase
  setup do
    @existing_user = users(:one)
  end

  test "should create a valid context" do
    context = Context.new(name: "context_1", latitude: 17.7928, longitude: 50.9196, user: @existing_user)
    assert context.save, "Failed to save a valid context"
  end

  test "should not save context without name, latitude, longitude or user" do
    context = Context.new(latitude: 17.7928, longitude: 50.9196, user: @existing_user)
    assert_not context.save, "Saved the context without a name"

    context = Context.new(name: "context_1", longitude: 50.9196, user: @existing_user)
    assert_not context.save, "Saved the context without a latitude"

    context = Context.new(name: "context_1", latitude: 17.7928, user: @existing_user)
    assert_not context.save, "Saved the context without a longitude"

    context = Context.new(name: "context_1", latitude: 17.7928, longitude: 50.9196)
    assert_not context.save, "Saved the context without a user"
  end

  test "should allow setting deleted_at" do
    context = Context.new(name: "context_1", latitude: 17.7928, longitude: 50.9196, user: @existing_user)
    context.update(deleted_at: Time.now)
    assert_not_nil context.deleted_at, "deleted_at not set correctly"
  end

  test "should perform soft delete" do
    context = Context.new(name: "context_1", latitude: 17.7928, longitude: 50.9196, user: @existing_user)
    context.update(deleted_at: Time.now)
    assert_not_nil context.deleted_at, "Context was not soft deleted"
  end
end
