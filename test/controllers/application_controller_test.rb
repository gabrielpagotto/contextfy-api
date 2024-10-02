require "test_helper"

class ApplicationControllerTest < ActionController::TestCase
  def setup
    @user = users(:one)
    @token = AuthHelper::JsonWebToken.encode(id: @user.id)
    @headers = { "Authorization" => "Bearer #{@token}" }
  end

  def test_authorize_request_success
    @controller.request.headers.merge!(@headers)
    get :auth_check

    assert_equal @user, assigns(:current_user)
    assert_response :success
  end

  def test_authorize_request_no_token
    @controller.request.headers["Authorization"] = nil
    get :auth_check

    assert_response :unauthorized
    assert_includes @response.body, "Unauthorized"
  end

  def test_authorize_request_invalid_token
    @controller.request.headers["Authorization"] = "Bearer invalid_token"
    get :auth_check

    assert_response :unauthorized
    assert_includes @response.body, "Unauthorized"
  end

  def test_authorize_request_user_not_found
    token = AuthHelper::JsonWebToken.encode(user_id: 99999)
    @controller.request.headers["Authorization"] = "Bearer #{token}"
    get :auth_check

    assert_response :unauthorized
    assert_includes @response.body, "Unauthorized"
  end

  def test_current_user
    @controller.instance_variable_set(:@current_user, @user)
    assert_equal @user, @controller.current_user
  end

  def test_current_user_when_not_set
    @controller.instance_variable_set(:@current_user, nil)
    assert_nil @controller.current_user
  end

  def test_spotify_service
    @controller.instance_variable_set(:@current_user, @user)
    get :auth_check
    spotify_service = @controller.spotify_service
    assert_instance_of SpotifyService, spotify_service
    assert_not_nil @user.sptf_access_token
  end
end
