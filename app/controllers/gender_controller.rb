class GenderController < ApplicationController
  include GenderHelper

  def index
    persisted_genders = Gender.where(user_id: current_user.id, deleted_at: nil)
    unless persisted_genders.any?
      render json: []
      return
    end
    render json: map_genders(persisted_genders.map { |gender| gender.sptf_gender_id }, persisted_genders)
  end

  def suggestions
    sptf_gender_ids = available_genders
    persisted_genders = Gender.where(user_id: current_user.id, sptf_gender_id: sptf_gender_ids, deleted_at: nil)
    render json: map_genders(sptf_gender_ids, persisted_genders)
  end

  def create
    persisted_genders = []
    errors = []
    ActiveRecord::Base.transaction do
      params[:sptf_gender_ids].each do |sptf_gender_id|
        gender = Gender.find_or_create_by(sptf_gender_id: sptf_gender_id, user_id: current_user.id, deleted_at: nil)
        unless gender.persisted?
          errors.push(gender.errors.full_messages)
          raise ActiveRecord::Rollback
        end
        persisted_genders.push gender
      end
    end
    if errors.empty?
      render json: map_genders(persisted_genders.map { |gender| gender.sptf_gender_id }, persisted_genders)
    else
      render json: { errors: errors.flatten }, status: :bad_request
    end
  rescue ActiveRecord::Rollback
    render json: { errors: errors.flatten }, status: :bad_request
  end

  def destroy
    gender = Gender.find(params[:id])
    if gender.update(deleted_at: Time.now)
      render json: gender, status: :no_content
    else
      render json: { errors: gender.errors.full_messages }, status: :bad_request
    end
  end

  private

  def available_genders
    top_artist = spotify_service.top_items(:artists)
    gender_suggestions = spotify_service.get_genres_suggestions
    sptf_gender_ids = top_artist["items"].map { |artist| artist["genres"] }
    sptf_gender_ids.append(gender_suggestions["genres"]).flatten.uniq.sort
  end

  def map_genders(genders, persisted_genders)
    genders_data = genders_data request.base_url
    genders.map do |item|
      {
        id: persisted_genders != nil ? persisted_genders.find { |gender| gender.sptf_gender_id == item }&.id : nil,
        name: genders_data.has_key?(item) ? genders_data[item] : item,
        sptf_gender_id: item
      }
    end
  end
end
