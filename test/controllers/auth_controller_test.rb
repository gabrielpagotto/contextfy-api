require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to Spotify OAuth2 URL" do
    get auth_spotify_oauth2_url
    assert_response :redirect
    assert_match %r{^https://accounts\.spotify\.com/authorize\?}, response.location
  end

  test "should return JSON when access_token is present" do
    get auth_spotify_oauth2_callback_url, params: {
      access_token: "some_token",
      token_type: "Bearer",
      expires_in: 3600
    }

    assert_response :success
    json_response = JSON.parse(response.body)

    assert_equal "some_token", json_response["access_token"]
    assert_equal "Bearer", json_response["token_type"]
    assert_equal 3600, json_response["expires_in"]
  end

  test " should render fragments_redirect when access_token is not present " do
    get auth_spotify_oauth2_callback_url
    assert_response :success
    assert_template "layouts/fragments_redirect"
  end
end
