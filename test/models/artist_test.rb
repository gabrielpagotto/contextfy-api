require "test_helper"

class ArtistTest < ActiveSupport::TestCase
  setup do
    @existing_user = users(:one)
  end

  test "should create a valid artist" do
    artist = Artist.new(sptf_artist_id: "spotify_12345", user: @existing_user)
    assert artist.save, "Failed to save a valid artist"
  end

  test "should not save artist without sptf_artist_id or user_id" do
    artist = Artist.new(user: @existing_user)
    assert_not artist.save, "Saved the artist without a sptf_artist_id"
    artist = Artist.new(sptf_artist_id: "spotify_12345")
    assert_not artist.save, "Saved the artist without a user_id"
  end

  test "should allow setting deleted_at" do
    artist = Artist.create(sptf_artist_id: "spotify_12345", user: @existing_user)
    artist.update(deleted_at: Time.now)
    assert_not_nil artist.deleted_at, "deleted_at not set correctly"
  end

  test "should perform soft delete" do
    artist = Artist.create(sptf_artist_id: "spotify_12345", user: @existing_user)
    artist.update(deleted_at: Time.now)
    assert_not_nil artist.deleted_at, "Artist was not soft deleted"
  end
end
