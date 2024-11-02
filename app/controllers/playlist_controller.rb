class PlaylistController < ApplicationController
  def index
    persisted_playlists = current_user.playlists.where(deleted_at: nil)
    unless persisted_playlists.any?
      render json: []
      return
    end
    playlists = persisted_playlists.map { |persisted_playlist|
      spotify_service.get_playlist persisted_playlist.sptf_playlist_id
    }
    render json: map_playlists(playlists, persisted_playlists)
  end

  def suggestions
    playlists = spotify_service.get_featured_playlists
    playlists = playlists["playlists"]["items"]
    sptf_playlist_ids = playlists.map { |item| item["id"] }
    persisted_playlists = current_user.playlists.where(sptf_playlist_id: sptf_playlist_ids, deleted_at: nil)
    render json: map_playlists(playlists, persisted_playlists)
  end

  def search
    unless params[:q].present?
      render json: { error: "Param `q` is required." }, status: :bad_request
      return
    end
    playlists = spotify_service.search(params[:q], :playlist)
    playlists = playlists["playlists"]["items"]
    sptf_playlist_ids = playlists.map { |item| item["id"] }
    persisted_artists = current_user.playlists.where(sptf_playlist_id: sptf_playlist_ids, deleted_at: nil)
    render json: map_playlists(playlists, persisted_artists)
  end

  def create
    persisted_playlists = []
    errors = []
    ActiveRecord::Base.transaction do
      params[:sptf_playlist_ids].each do |sptf_playlist_id|
        playlist = current_user.playlists.find_or_create_by(sptf_playlist_id: sptf_playlist_id, deleted_at: nil)
        unless playlist.persisted?
          errors.push(playlist.errors.full_messages)
          raise ActiveRecord::Rollback
        end
        persisted_playlists.push playlist
      end
    end
    if errors.empty?
      playlists = persisted_playlists.map { |persisted_playlist|
        spotify_service.get_playlist persisted_playlist.sptf_playlist_id
      }
      render json: map_playlists(playlists, persisted_playlists)
    else
      render json: { errors: errors.flatten }, status: :bad_request
    end
  rescue ActiveRecord::Rollback
    render json: { errors: errors.flatten }, status: :bad_request
  end

  def destroy
    playlist = current_user.playlists.where(deleted_at: nil).find(params[:id])
    if playlist.update(deleted_at: Time.now)
      render json: playlist, status: :no_content
    else
      render json: { errors: playlist.errors.full_messages }, status: :bad_request
    end
  end

  private

  def map_playlists(playlists, persisted_playlists)
    playlists.map { |item| {
      id: persisted_playlists != nil ? persisted_playlists.find { |playlist| playlist.sptf_playlist_id == item["id"] }&.id : nil,
      sptf_playlist_id: item["id"],
      name: item["name"],
      images: item["images"]
    } }
  end
end
