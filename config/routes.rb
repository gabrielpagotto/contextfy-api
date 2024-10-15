Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
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
  post "contexts" => "context#create"
  delete "contexts/:id" => "context#destroy"
end
