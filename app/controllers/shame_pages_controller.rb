class ShamePagesController < ActionController::Base
  skip_before_action :verify_authenticity_token, raise: false

  # GET /p/:slug
  # Public shame page - no authentication required
  def show
    @user = User.find_by(page_slug: params[:slug])

    unless @user
      render :not_found, status: :not_found
      return
    end

    # Check if shame is active and image exists
    @shame_visible = @user.shame_visible?

    if @shame_visible
      # Generate a signed URL that expires in 15 minutes
      @image_url = signed_image_url(@user)
    end

    @shame_activated_at = @user.shame_activated_at

    render :show
  end

  private

  # Generate a time-limited signed URL for the image
  def signed_image_url(user)
    return nil unless user.profile_image.attached?

    # Use Active Storage's signed URL with expiration
    user.profile_image.url(expires_in: 15.minutes)
  rescue => e
    Rails.logger.error "Failed to generate signed URL: #{e.message}"
    nil
  end
end
