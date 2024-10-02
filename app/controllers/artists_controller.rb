class ArtistsController < ApplicationController
  def search
    unless params[:q].present?
      render json: { error: "Param `q` is required." }, status: :bad_request
      return
    end

    render json: spotify_service.search(params[:q], :artist)
  end
end
