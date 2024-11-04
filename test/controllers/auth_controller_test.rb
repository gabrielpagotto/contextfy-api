require "test_helper"
require "minitest/mock"

class AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @spotify_service_mock = Minitest::Mock.new
    @user_profile = { "id" => "spotify_user_id_123" }
    @existing_user = users(:one)
    @controller = AuthController.new
    @user = User.create!(sptf_user_id: "test_user_id", deleted_at: nil)
  end

  test "should redirect to Spotify OAuth2 URL" do
    original_env = ENV.to_h

    get auth_spotify_oauth2_url
    assert_response :redirect
    assert_match %r{^https://fictitious-accounts\.spotify\.com/authorize\?}, response.location

  ensure
    original_env.each { |key, value| ENV[key] = value }
  end

  test "should handle spotify oauth2 callback and create new user" do
    @spotify_service_mock.expect :set_access_token, nil, ["fake_access_token"]
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
    @spotify_service_mock.expect :set_access_token, nil, ["fake_access_token"]
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

  test "create_new_user should return a new user instance" do
    sptf_token_type = "Bearer"
    sptf_access_token = "fake_access_token"
    sptf_expires_in = 3600

    user = @controller.send(:create_new_user, "new_sptf_user_id", sptf_access_token, sptf_token_type, sptf_expires_in)

    assert user.new_record?, "User should be a new record"
    assert_equal "new_sptf_user_id", user.sptf_user_id
    assert_equal sptf_token_type, user.sptf_token_type
    assert_equal sptf_expires_in, user.sptf_expires_in
  end

  test "spotify_oauth2_url should return a valid URL" do
    url = @controller.send(:spotify_oauth2_url)

    assert_match /https:\/\/fictitious-accounts\.spotify\.com\/authorize/, url, "URL should contain Spotify authorization endpoint"
    assert_match /response_type=code/, url, "URL should contain response_type parameter"
    assert_match /client_id=test_client_id/, url, "URL should contain client_id parameter"
    assert_match /redirect_uri=#{CGI.escape("http://localhost:3000/auth/spotify/oauth2/test_callback")}/, url, "URL should contain redirect_uri parameter"
    assert_match /scope=user-read-email\+user-library-read/, url, "URL should contain scopes parameter"
  end
end
