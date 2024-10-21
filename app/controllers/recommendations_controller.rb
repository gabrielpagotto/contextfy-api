class RecommendationsController < ApplicationController
  def index
    context_id = params[:context_id] # TODO: Implement recommendation from context.

    artists = current_user.artists.where(deleted_at: nil).order(created_at: :asc).limit(3)
    genres = current_user.genders.where(deleted_at: nil).order(created_at: :asc).limit(2)
    recommendations = spotify_service.get_recommendations 60, artists.pluck(:sptf_artist_id), genres.pluck(:sptf_gender_id)

    tracks = recommendations["tracks"].select { |track|
      track["type"] == "track" && track["is_playable"] && track["preview_url"].present?
    }

    render json: tracks.map { |track| {
      id: track["id"],
      name: track["name"],
      preview_url: track["preview_url"],
      uri: track["uri"],
      type: track["type"],
      images: track["album"]["images"],
      artists: track["artists"].map { |artist| {
        id: artist["id"],
        name: artist["name"],
      } }
    } }
  end
end
