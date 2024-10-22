class RatedTracksController < ApplicationController
  def toggle
    rated_track = current_user.rated_tracks.where(
      rate: params[:rate],
      context_id: params[:context_id],
      sptf_track_id: params[:sptf_track_id],
      deleted_at: nil
    ).first
    if rated_track.present?
      rated_track.deleted_at = Time.now
      rated_track.save
      render json: rated_track
    else
      current_user.rated_tracks.where(
        context_id: params[:context_id],
        sptf_track_id: params[:sptf_track_id],
        deleted_at: nil
      ).each do |rated_track_to_delete|
        rated_track_to_delete.deleted_at = Time.now
        rated_track_to_delete.save
      end
      rated_track = current_user.rated_tracks.create(toggle_params)
      if rated_track.save
        render json: rated_track
      else
        render json: rated_track.errors, status: :unprocessable_content
      end
    end
  end

  private

  def toggle_params
    params.permit(:rate, :context_id, :sptf_track_id)
  end
end
