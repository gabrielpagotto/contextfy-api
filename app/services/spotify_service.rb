class SpotifyService

  def set_access_token(access_token)
    @access_token = access_token
  end

  def current_user_profile
    response = call "/me", :get
    handle_response response
  end

  def search(q, type)
    response = call "/search", :get, query: { q: q, type: type }
    handle_response response
  end

  private

  @access_token = nil
  SPOTIFY_API_URL = "https://api.spotify.com/v1"

  def call(path, method, body = nil, query_params = {})
    url = "#{SPOTIFY_API_URL}#{path}"
    url = "#{url}?#{URI.encode_www_form(query_params)}" unless query_params.empty?

    Faraday.send(method, url) do |req|
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
