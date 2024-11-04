ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    ENV["SPOTIFY_API_HOST"] = "https://fictitious-api.spotify.com"
    ENV["SPOTIFY_AUTH_HOST"] = "https://fictitious-accounts.spotify.com"
    ENV["SPOTIFY_CLIENT_ID"] = "test_client_id"
    ENV["SPOTIFY_CLIENT_SECRET"] = "test_client_secret"
    ENV["SPOTIFY_REDIRECT_URI"] = "http://localhost:3000/auth/spotify/oauth2/test_callback"
    ENV["SPOTIFY_RESPONSE_TYPE"] = "code"
    ENV["SPOTIFY_SCOPE"] = "user-read-email user-library-read"
  end
end
