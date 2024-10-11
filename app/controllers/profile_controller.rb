class ProfileController < ApplicationController
  def me
    render json: spotify_service.current_user_profile
  end
end
