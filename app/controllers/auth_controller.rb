class AuthController < ActionController::Base

  def spotify_oauth2
    redirect_to spotify_oauth2_url, allow_other_host: true
  end

  def spotify_oauth2_callback
    if params[:access_token].present?
      render json: {
        "access_token": params[:access_token],
        "token_type": params[:token_type],
        "expires_in": params[:expires_in].to_i
      }
    else
      render :'layouts/fragments_redirect'
    end
  end

  private

  API_HOST = "https://api.spotify.com"
  AUTH_HOST = "https://accounts.spotify.com"
  CLIENT_ID = "32719c0e79af41f68efd36ff156ec3f1"
  CLIENT_SECRET = "6e893b895057419a869fc70291fdcbb2"
  REDIRECT_URI = "http://localhost:3000/auth/spotify/oauth2/callback"
  RESPONSE_TYPE = "token"
  SCOPES = "user-read-private"

  def spotify_oauth2_url
    params = {
      "response_type" => RESPONSE_TYPE,
      "client_id" => CLIENT_ID,
      "redirect_uri" => REDIRECT_URI,
      "scopes" => SCOPES
    }

    base_url = URI.join(AUTH_HOST, "/authorize")
    base_url.query = URI.encode_www_form(params)
    base_url.to_s
  end
end
