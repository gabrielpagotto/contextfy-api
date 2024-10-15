class ContextController < ApplicationController
  def index
    render json: current_user.contexts.where(deleted_at: nil)
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
