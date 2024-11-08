require "test_helper"
require "minitest/mock"

class AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["SPOTIFY_API_HOST"] = "https://fictitious-api.spotify.com"
    ENV["SPOTIFY_AUTH_HOST"] = "https://fictitious-accounts.spotify.com"
    ENV["SPOTIFY_CLIENT_ID"] = "test_client_id"
    ENV["SPOTIFY_CLIENT_SECRET"] = "test_client_secret"
    ENV["SPOTIFY_REDIRECT_URI"] = "http://localhost:3000/auth/spotify/oauth2/test_callback"
    ENV["SPOTIFY_RESPONSE_TYPE"] = "code"
    ENV["SPOTIFY_SCOPE"] = "user-read-email user-library-read"

    @spotify_service_mock = Minitest::Mock.new
    @user_profile = { "id" => "spotify_user_id_123" }
    @existing_user = users(:one)
    @controller = AuthController.new
    @user = User.create!(sptf_user_id: "test_user_id", deleted_at: nil)
  end

  test "should redirect to Spotify OAuth2 URL" do
    get auth_spotify_oauth2_url
    assert_response :redirect
    assert_match %r{^https://fictitious-accounts\.spotify\.com/authorize\?}, response.location
  end

  test "should handle spotify oauth2 callback and create new user" do
    @spotify_service_mock.expect :set_access_token, nil, [ "fake_access_token" ]
    @spotify_service_mock.expect :current_user_profile, @user_profile

    SpotifyService.stub :new, @spotify_service_mock do
      get auth_spotify_oauth2_callback_url, params: {
        access_token: "fake_access_token",
        token_type: "Bearer",
        expires_in: 3600
      }

      user = User.find_by(sptf_user_id: @user_profile["id"])
      assert user.present?, "User should be created"
      assert_equal "Bearer", user.sptf_token_type
      assert_equal 3600, user.sptf_expires_in

      json_response = JSON.parse(response.body)
      assert json_response["access_token"].present?, "Access token should be returned"
      assert_response :success
    end

    assert_mock @spotify_service_mock
  end

  test "should update existing user on spotify oauth2 callback" do
    @spotify_service_mock.expect :set_access_token, nil, [ "fake_access_token" ]
    @spotify_service_mock.expect :current_user_profile, { "id" => @existing_user.sptf_user_id }

    SpotifyService.stub :new, @spotify_service_mock do
      get auth_spotify_oauth2_callback_url, params: {
        access_token: "fake_access_token",
        token_type: "Bearer",
        expires_in: 3600
      }

      @existing_user.reload
      assert_equal "Bearer", @existing_user.sptf_token_type
      assert_equal 3600, @existing_user.sptf_expires_in

      json_response = JSON.parse(response.body)
      assert json_response["access_token"].present?, "Access token should be returned"
      assert_response :success
    end

    assert_mock @spotify_service_mock
  end

  test " should render fragments_redirect when access_token is not present " do
    get auth_spotify_oauth2_callback_url
    assert_response :success
    assert_template "layouts/fragments_redirect"
  end

  test "generate_token should return a valid token for a user" do
    token = @controller.send(:generate_token, @user.id)
    decoded_token = AuthHelper::JsonWebToken.decode(token)

    assert_equal @user.id, decoded_token["id"], "Token should contain the user ID"
  end

  test "should redirect to Spotify OAuth2 URL" do
    original_env = ENV.to_h

    ENV["SPOTIFY_AUTH_HOST"] = "https://fictitious-accounts.spotify.com"
    ENV["SPOTIFY_CLIENT_ID"] = "test_client_id"
    ENV["SPOTIFY_REDIRECT_URI"] = "http://localhost:3000/auth/spotify/oauth2/test_callback"
    ENV["SPOTIFY_SCOPE"] = "user-read-email user-library-read"

    get auth_spotify_oauth2_url
    assert_response :redirect
    assert_match %r{^https://fictitious-accounts\.spotify\.com/authorize\?}, response.location

  ensure
    original_env.each { |key, value| ENV[key] = value }
  end

  test "spotify_oauth2_url should return a valid URL" do
    original_env = ENV.to_h

    ENV["SPOTIFY_AUTH_HOST"] = "https://fictitious-accounts.spotify.com"
    ENV["SPOTIFY_CLIENT_ID"] = "test_client_id"
    ENV["SPOTIFY_REDIRECT_URI"] = "http://localhost:3000/auth/spotify/oauth2/test_callback"
    ENV["SPOTIFY_SCOPE"] = "user-read-email user-library-read"

    url = @controller.send(:spotify_oauth2_url)
    assert_match %r{^https://fictitious-accounts\.spotify\.com/authorize}, url, "URL should contain Spotify authorization endpoint"
    assert_match /response_type=code/, url, "URL should contain response_type parameter"
    assert_match /client_id=test_client_id/, url, "URL should contain client_id parameter"
    assert_match /redirect_uri=#{CGI.escape("http://localhost:3000/auth/spotify/oauth2/test_callback")}/, url, "URL should contain redirect_uri parameter"
    assert_match /scope=user-read-email\+user-library-read/, url, "URL should contain scopes parameter"

  ensure
    original_env.each { |key, value| ENV[key] = value }
  end
end
