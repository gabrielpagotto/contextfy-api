class RecommendationsController < ApplicationController
  def index
    context_id = params[:context_id]
    context = context_id.present? ? current_user.contexts.where(deleted_at: nil).find(context_id.to_i) : nil
    rated_tracks = context.present? ? context.rated_tracks.where(deleted_at: nil).order(rate: :desc) : []

    if rated_tracks.present?
      recommendations = spotify_service.get_recommendations(limit: 60, market: "BR", min_popularity: 60, max_popularity: 100,
                                                            target_popularity: 90,
                                                            seed_tracks: rated_tracks.take(5).pluck(:sptf_track_id).join(","))
      recommendations = recommendations["tracks"]
    else
      artists = current_user.artists.where(deleted_at: nil).order(Arel.sql("RANDOM()")).limit(4)
      genres = current_user.genders.where(deleted_at: nil).order(Arel.sql("RANDOM()")).limit(1)

      artist_gender_recommendations = spotify_service.get_recommendations(limit: 60, market: "BR", min_popularity: 60, max_popularity: 100,
                                                                          target_popularity: 90,
                                                                          seed_artists: artists.pluck(:sptf_artist_id).join(","),
                                                                          seed_genres: genres.pluck(:sptf_gender_id).join(","))

      playlists = current_user.playlists.where(deleted_at: nil).order(Arel.sql("RANDOM()")).limit(2)
      track_ids = []
      playlists_recommendations = []

      playlists.each do |playlist|
        sptf_playlist = spotify_service.get_playlist playlist.sptf_playlist_id
        track_ids.concat(sptf_playlist["tracks"]["items"].map { |track| track["track"]["id"] })
      end

      if track_ids.present?
        playlists_recommendations = spotify_service.get_recommendations(limit: 60, market: "BR", min_popularity: 60, max_popularity: 100,
                                                                        target_popularity: 90,
                                                                        seed_tracks: track_ids.take(5).join(","))
      end

      recommendations = [ *artist_gender_recommendations["tracks"], *playlists_recommendations["tracks"] ]
    end

    tracks = recommendations.select { |track|
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
      artists: track["artists"].map { |artist| { sptf_artist_id: artist["id"], name: artist["name"] } }
    } }
  end
end
