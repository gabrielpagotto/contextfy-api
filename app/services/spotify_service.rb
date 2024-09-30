class SpotifyService
  def initialize(access_token)
    @access_token = access_token
  end

  def current_user_profile
    response = Faraday.get("#{SPOTIFY_API_URL}/me") do |req|
      req.headers["Authorization"] = "Bearer #{@access_token}"
      req.headers["Content-Type"] = "application/json"
    end
    if response.status == 200
      JSON.parse(response.body)
    else
      { error: response.status, message: "Failed to retrieve user profile" }
    end
  end

  private

  SPOTIFY_API_URL = "https://api.spotify.com/v1"
end
