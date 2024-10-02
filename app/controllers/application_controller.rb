require "jwt"

class ApplicationController < ActionController::API
  before_action :authorize_request

  def authorize_request
    unless request.headers["Authorization"].present?
      raise UnauthorizedError, "Authorization header not found."
    end

    header = request.headers["Authorization"]
    token = header.split(" ").last
    decoded = AuthHelper::JsonWebToken.decode(token)

    unless decoded && decoded[:user_id]
      raise UnauthorizedError, "Invalid token or user ID not found."
    end

    @current_user = User.find(decoded[:user_id])

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
    SpotifyService.new do |service|
      service.set_access_token @current_user.sptf_access_token
    end
  end
end
