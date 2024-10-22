class RecommendationsController < ApplicationController
  def index
    context_id = params[:context_id] # TODO: Implement recommendation from context.

    artists = current_user.artists.where(deleted_at: nil).order(created_at: :asc).limit(3)
    genres = current_user.genders.where(deleted_at: nil).order(created_at: :asc).limit(2)

    recommendations = spotify_service.get_recommendations(limit: 60, market: "BR", min_popularity: 60, max_popularity: 100,
                                                          target_popularity: 90,
                                                          seed_artists: artists.pluck(:sptf_artist_id).join(","),
                                                          seed_genres: genres.pluck(:sptf_gender_id).join(","))

    tracks = recommendations["tracks"].select { |track|
      track["type"] == "track" && track["is_playable"] && track["preview_url"].present?
    }

    rated_tracks = current_user.rated_tracks.where(sptf_track_id: tracks.pluck("id"), deleted_at: nil)

    render json: tracks.map { |track| {
      sptf_track_id: track["id"],
      name: track["name"],
      preview_url: track["preview_url"],
      uri: track["uri"],
      type: track["type"],
      images: track["album"]["images"],
      rate: rated_tracks.find { |rated_track| rated_track.sptf_track_id == track["id"] },
      artists: track["artists"].map { |artist| {
        sptf_artist_id: artist["id"],
        name: artist["name"]
      } }
    } }
  end
end
