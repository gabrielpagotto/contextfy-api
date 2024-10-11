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

  TOP_ITEMS_TYPES = {
    artists: "artists"
  }.freeze

  def search(q, type)
    raise ArgumentError, "Invalid type" unless SEARCH_TYPES.key?(type)
    response = call "/v1/search", :get, nil, { q: q, type: SEARCH_TYPES[type] }
    handle_response response
  end

  def top_items(type)
    raise ArgumentError, "Invalid type" unless TOP_ITEMS_TYPES.key?(type)
    response = call "/v1/me/top/#{type}", :get
    handle_response response
  end

  def get_several_artists(sptf_ids)
    response = call "/v1/artists", :get, nil, { ids: sptf_ids.join(",") }
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
      raise SpotifyServiceError.new("An error occurred with Spotify Service", response.status, JSON.parse(response.body))
    end
  end
end

class SpotifyServiceError < StandardError
  attr_reader :status, :body

  def initialize(msg, status = nil, body = nil)
    @status = status
    @body = body
    super(msg)
  end
end
