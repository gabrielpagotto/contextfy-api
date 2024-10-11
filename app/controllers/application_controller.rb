require "jwt"

class ApplicationController < ActionController::API
  before_action :authorize_request
  rescue_from SpotifyServiceError, with: :handle_spotify_service_error

  def authorize_request
    unless request.headers["Authorization"].present?
      raise UnauthorizedError, "Authorization header not found."
    end

    header = request.headers["Authorization"]
    token = header.split(" ").last
    decoded = AuthHelper::JsonWebToken.decode(token)

    unless decoded && decoded[:id]
      raise UnauthorizedError, "Invalid token or user ID not found."
    end

    @current_user = User.find(decoded[:id])

  rescue => e
    render json: { errors: "Unauthorized" }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def auth_check
    render json: { message: "Authorized" }, status: :ok
  end

  def spotify_service
    s = SpotifyService.new
    s.set_access_token @current_user.sptf_access_token
    s
  end

  def handle_spotify_service_error(exception)
    if exception.status == 401
      render json: { errors: "Unauthorized" }, status: :unauthorized
    end
    render json: exception.body, status: exception.status
  end
end
