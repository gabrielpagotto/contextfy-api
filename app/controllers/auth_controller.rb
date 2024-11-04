class AuthController < ActionController::Base
  def spotify_service
    @spotify_service ||= SpotifyService.new
  end

  def spotify_oauth2
    redirect_to spotify_oauth2_url, allow_other_host: true
  end

  def spotify_oauth2_callback
    if params[:access_token].present?
      sptf_access_token = params[:access_token]
      sptf_token_type = params[:token_type]
      sptf_expires_in = params[:expires_in].to_i

      spotify_service.set_access_token sptf_access_token

      user_profile = spotify_service.current_user_profile
      sptf_user_id = user_profile["id"]

      user = User.find_by(sptf_user_id: sptf_user_id, deleted_at: nil)

      if user.present?
        token = generate_token(user.id)
        user.update(
          sptf_access_token: sptf_access_token,
          sptf_token_type: sptf_token_type,
          sptf_expires_in: sptf_expires_in
        )
      else
        user = create_new_user sptf_user_id, sptf_access_token, sptf_token_type, sptf_expires_in
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

  API_HOST = ENV["SPOTIFY_API_HOST"]
  AUTH_HOST = ENV["SPOTIFY_AUTH_HOST"]
  CLIENT_ID = ENV["SPOTIFY_CLIENT_ID"]
  CLIENT_SECRET = ENV["SPOTIFY_CLIENT_SECRET"]
  REDIRECT_URI = ENV["SPOTIFY_REDIRECT_URI"]
  RESPONSE_TYPE = ENV["SPOTIFY_RESPONSE_TYPE"]
  SCOPE = ENV["SPOTIFY_SCOPE"]

  def spotify_oauth2_url
    params = {
      "response_type" => RESPONSE_TYPE,
      "client_id" => CLIENT_ID,
      "redirect_uri" => REDIRECT_URI,
      "scope" => SCOPE
    }

    base_url = URI.join(AUTH_HOST, "/authorize")
    base_url.query = URI.encode_www_form(params)
    base_url.to_s
  end

  def generate_token(user_id)
    AuthHelper::JsonWebToken.encode({ id: user_id })
  end

  def create_new_user(sptf_user_id, sptf_access_token, sptf_token_type, sptf_expires_in)
    User.new(
      sptf_user_id: sptf_user_id,
      sptf_access_token: sptf_access_token,
      sptf_token_type: sptf_token_type,
      sptf_expires_in: sptf_expires_in
    )
  end
end
