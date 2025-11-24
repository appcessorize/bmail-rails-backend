class ImagesController < ApplicationController
  before_action :set_user

  def show
    # Check if image exists
    unless @user.profile_image.attached?
      return render json: { error: "Image not found" }, status: :not_found
    end

    # If image is public, allow access
    if @user.image_public
      redirect_to rails_blob_url(@user.profile_image), allow_other_host: true
      return
    end

    # If image is private, require authentication
    authenticate_user!

    # Only allow user to view their own private image
    unless current_user && current_user.id == @user.id
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    # Serve the image
    redirect_to rails_blob_url(@user.profile_image), allow_other_host: true
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end
end
