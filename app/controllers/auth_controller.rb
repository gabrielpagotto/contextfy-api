class AuthController < ActionController::Base

  def spotify_oauth2
    redirect_to spotify_oauth2_url, allow_other_host: true
  end

  def spotify_oauth2_callback
    if params[:access_token].present?
      access_token = params[:access_token]
      token_type = params[:token_type]
      expires_in = params[:expires_in].to_i

      spotify_service = SpotifyService.new(access_token)
      user_profile = spotify_service.current_user_profile
      sptf_user_id = user_profile["id"]

      user = User.find_by(sptf_user_id: sptf_user_id, deleted_at: nil)

      if user.present?
        token = generate_token(user.id)
        user.update(
          sptf_access_token: token,
          sptf_token_type: token_type,
          sptf_expires_in: expires_in
        )
      else
        user = create_new_user sptf_user_id, token_type, expires_in
        unless user.save
          return render json: { error: user.errors }, status: :bad_request
        end
        token = generate_token(user.id)
      end

      render json: { access_token: token }
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

  def generate_token(user_id)
    AuthHelper::JsonWebToken.encode({ id: user_id })
  end

  def create_new_user(sptf_user_id, token_type, expires_in)
    User.new(
      sptf_user_id: sptf_user_id,
      sptf_access_token: generate_token(nil),
      sptf_token_type: token_type,
      sptf_expires_in: expires_in
    )
  end
end
