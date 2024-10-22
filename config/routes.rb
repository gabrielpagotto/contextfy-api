Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "auth_check" => "application#auth_check"

  get "auth/spotify/oauth2" => "auth#spotify_oauth2"
  get "auth/spotify/oauth2/callback" => "auth#spotify_oauth2_callback"

  get "profile/me" => "profile#me"

  get "artists" => "artists#index"
  get "artists/suggestions" => "artists#suggestions"
  get "artists/search" => "artists#search"
  post "artists" => "artists#create"
  delete "artists/:id" => "artists#destroy"

  get "genres" => "gender#index"
  get "genres/suggestions" => "gender#suggestions"
  post "genres" => "gender#create"
  delete "genres/:id" => "gender#destroy"

  get "contexts" => "context#index"
  get "contexts/current" => "context#current"
  post "contexts" => "context#create"
  delete "contexts/:id" => "context#destroy"

  get "recommendations" => "recommendations#index"

  post "rates/track/toggle" => "rated_tracks#toggle"
end
