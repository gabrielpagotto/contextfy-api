class SpotifyService
  def initialize(access_token)
    @access_token = access_token
  end

  def current_user_profile
    response = call "/me", :get
    handle_response response
  end

  private

  SPOTIFY_API_URL = "https://api.spotify.com/v1"

  def call(path, method, body = nil)
    Faraday.send(method, "#{SPOTIFY_API_URL}/#{path}") do |req|
      req.headers["Authorization"] = "Bearer #{@access_token}"
      req.headers["Content-Type"] = "application/json"
      req.body = body.to_json if body
    end
  end

  def handle_response(response)
    if response.status == 200
      JSON.parse(response.body)
    else
      { error: response.status, message: JSON.parse(response.body) }
    end
  end
end
