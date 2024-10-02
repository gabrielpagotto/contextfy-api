class SpotifyService

  def initialize
    @conn = Faraday.new(url: "#{SPOTIFY_API_URL}") do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end

  def set_access_token(access_token)
    @access_token = access_token
  end

  def current_user_profile
    response = call "/v1/me", :get
    handle_response response
  end

  SEARCH_TYPES = {
    artist: "artist",
    gender: "gender"
  }.freeze

  def search(q, type)
    raise ArgumentError, "Invalid type" unless SEARCH_TYPES.key?(type)
    response = call "/v1/search", :get, nil, { q: q, type: SEARCH_TYPES[type] }
    handle_response response
  end

  private

  @access_token
  SPOTIFY_API_URL = "https://api.spotify.com"

  def call(path, method, body = nil, params = {}, headers = {})
    @conn.send(method, path, params) do |req|
      req.headers["Authorization"] = "Bearer #{@access_token}"
      req.headers["Content-Type"] = "application/json"
      req.body = body.to_json if body
    end
  end

  def handle_response(response)
    if response.status == 200
      JSON.parse(response.body)
    else
      { source: "spotify", **JSON.parse(response.body) }
    end
  end
end
