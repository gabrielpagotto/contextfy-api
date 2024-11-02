class ContextController < ApplicationController
  include ContextHelper

  def index
    render json: current_user.contexts.where(deleted_at: nil)
  end

  def current
    required_params = %i[latitude longitude radius]
    missing_params = required_params.select { |param| !params[param].present? }

    if missing_params.any?
      render json: { error: "Param(s) #{missing_params.join(', ')} is/are required." }, status: :bad_request
      return
    end

    radius = params[:radius].to_i
    c_lat, c_lng = params[:latitude].to_f, params[:longitude].to_f

    user_contexts = current_user.contexts.where(deleted_at: nil)
    context_minus_distance = nil
    last_distance = radius + 1
    user_contexts.each do |user_context|
      distance = HaversineCalculator.haversine_distance(c_lat, c_lng, user_context.latitude, user_context.longitude)
      if distance <= radius && distance < last_distance
        last_distance = distance
        context_minus_distance = user_context
      end
    end

    if context_minus_distance.present?
      render json: context_minus_distance
      return
    end

    render json: { details: "No context found within #{radius} meters." }, status: :bad_request
  end

  def create
    context = current_user.contexts.new(context_params)
    if context.save
      render json: context
    else
      render json: { errors: context.errors.full_messages }
    end
  end

  def destroy
    context = current_user.contexts.where(deleted_at: nil).find(params[:id])
    if context.update(deleted_at: Time.now)
      render json: context, status: :no_content
    else
      render json: { errors: context.errors.full_messages }
    end
  end

  private

  def context_params
    params.permit(:name, :latitude, :longitude)
  end
end
