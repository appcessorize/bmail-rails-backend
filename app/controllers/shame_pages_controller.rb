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

    @shame_visible = @user.shame_visible?
    @has_image = @shame_visible && @user.profile_image.attached?
    @shame_activated_at = @user.shame_activated_at

    render :show
  end

  # GET /p/:slug/image
  # Serves the shame image via redirect to a fresh signed URL.
  # The shame page HTML points here so the link never goes stale.
  def image
    user = User.find_by(page_slug: params[:slug])

    unless user&.shame_visible? && user.profile_image.attached?
      head :not_found
      return
    end

    redirect_to user.profile_image.url(expires_in: 15.minutes), allow_other_host: true
  end

  private

  def find_shame_user
    User.find_by(page_slug: params[:slug])
  end
end
