require "test_helper"
require "faraday"
require "webmock/minitest"
require "ostruct"

class SpotifyServiceTest < ActiveSupport::TestCase
  def setup
    @service = SpotifyService.new
  end

  def test_set_access_token
    @service.set_access_token("test_access_token")
    assert_equal "test_access_token", @service.instance_variable_get(:@access_token)
  end

  def test_current_user_profile
    stub_request(:get, "https://api.spotify.com/v1/me")
      .with(headers: { "Authorization" => "Bearer test_access_token" })
      .to_return(status: 200, body: { id: "user_id", name: "User Name" }.to_json, headers: { "Content-Type" => "application/json" })

    @service.set_access_token("test_access_token")
    user_profile = @service.current_user_profile

    assert_equal "user_id", user_profile["id"]
    assert_equal "User Name", user_profile["name"]
  end

  def test_search_artist
    stub_request(:get, "https://api.spotify.com/v1/search")
      .with(
        query: { q: "Avenged", type: "artist" },
        headers: { "Authorization" => "Bearer test_access_token" }
      )
      .to_return(status: 200, body: {
        artists: {
          items: [
            {
              name: "Avenged Sevenfold",
              id: "12345"
            }
          ],
          limit: 20,
          href: "https://api.spotify.com/v1/search?q=Avenged&type=artist"
        }
      }.to_json, headers: { "Content-Type" => "application/json" })

    @service.set_access_token "test_access_token"
    response = @service.search "Avenged", :artist

    assert_equal 20, response["artists"]["limit"]
    assert_equal "https://api.spotify.com/v1/search?q=Avenged&type=artist", response["artists"]["href"]
    assert_equal "Avenged Sevenfold", response["artists"]["items"][0]["name"]
  end

  def test_handle_response_with_success
    response = OpenStruct.new(status: 200, body: { id: "user_id" }.to_json)
    result = @service.send(:handle_response, response)

    assert_equal "user_id", result["id"]
  end

  def test_handle_response_with_error
    response = OpenStruct.new(status: 400, body: { error: "Bad Request" }.to_json)

    error = assert_raises(SpotifyServiceError) do
      @service.send(:handle_response, response)
    end

    assert_equal error.status, 400
    assert_equal "Bad Request", error.body["error"]
  end

  def test_call_method
    stub_request(:get, "https://api.spotify.com/v1/test")
      .with(headers: { "Authorization" => "Bearer test_access_token" })
      .to_return(status: 200, body: { success: true }.to_json, headers: { "Content-Type" => "application/json" })

    @service.set_access_token("test_access_token")
    response = @service.send(:call, "/v1/test", :get)

    assert_equal true, JSON.parse(response.body)["success"]
  end
end
