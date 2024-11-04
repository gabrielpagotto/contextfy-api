class ArtistsController < ApplicationController
  def index
    persisted_artists = current_user.artists.where(deleted_at: nil)
    unless persisted_artists.any?
      render json: []
      return
    end
    result = spotify_service.get_several_artists persisted_artists.map { |artist| artist.sptf_artist_id }
    render json: map_artists(result["artists"], persisted_artists)
  end

  def suggestions
    result = spotify_service.top_items(:artists)
    unless result.empty?
      result = spotify_service.search("a", :artist)["artists"]
    end
    sptf_artist_ids = result["items"].map { |item| item["id"] }
    persisted_artists = current_user.artists.where(sptf_artist_id: sptf_artist_ids, deleted_at: nil)
    render json: map_artists(result["items"], persisted_artists)
  end

  def search
    unless params[:q].present?
      render json: { error: "Param `q` is required." }, status: :bad_request
      return
    end

    result = spotify_service.search(params[:q], :artist)
    sptf_artist_ids = result["artists"]["items"].map { |item| item["id"] }
    persisted_artists = current_user.artists.where(sptf_artist_id: sptf_artist_ids, deleted_at: nil)
    render json: map_artists(result["artists"]["items"], persisted_artists)
  end

  def create
    persisted_artists = []
    errors = []
    ActiveRecord::Base.transaction do
      params[:sptf_artist_ids].each do |sptf_artist_id|
        artist = current_user.artists.find_or_create_by(sptf_artist_id: sptf_artist_id, deleted_at: nil)
        unless artist.persisted?
          errors.push(artist.errors.full_messages)
          raise ActiveRecord::Rollback
        end
        persisted_artists.push artist
      end
    end
    if errors.empty?
      result = spotify_service.get_several_artists persisted_artists.map { |artist| artist.sptf_artist_id }
      render json: map_artists(result["artists"], persisted_artists)
    else
      render json: { errors: errors.flatten }, status: :bad_request
    end
  rescue ActiveRecord::Rollback
    render json: { errors: errors.flatten }, status: :bad_request
  end

  def destroy
    artist = current_user.artists.where(deleted_at: nil).find(params[:id])
    if artist.update(deleted_at: Time.now)
      render json: artist, status: :no_content
    else
      render json: { errors: artist.errors.full_messages }, status: :bad_request
    end
  end

  private

  def map_artists(artists, persisted_artists)
    artists.map { |item| {
      id: persisted_artists != nil ? persisted_artists.find { |artist| artist.sptf_artist_id == item["id"] }&.id : nil,
      sptf_artist_id: item["id"],
      name: item["name"],
      images: item["images"],
      genres: item["genres"]
    } }
  end
end
