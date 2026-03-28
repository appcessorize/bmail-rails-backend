class AdminController < ActionController::Base
  before_action :authorize_admin!
  skip_before_action :verify_authenticity_token, raise: false

  def dashboard
    @stats = {
      total_users: User.count,
      users_with_images: User.joins(:profile_image_attachment).distinct.count,
      active_shame: User.where(shame_active: true).count,
      total_sessions: FocusSession.count,
      failed_sessions: FocusSession.where(status: 'failed').count,
      completed_sessions: FocusSession.where(status: 'completed').count,
      unresolved_reports: Report.where(resolved: false).count,
      unread_contacts: Contact.where(read: false).count
    }
    @users = User.order(created_at: :desc).limit(50)
    @recent_sessions = FocusSession.includes(:user).order(created_at: :desc).limit(20)
    @reports = Report.order(created_at: :desc).limit(20)
    @contacts = Contact.order(created_at: :desc).limit(20)

    render :dashboard, layout: false
  end

  private

  def authorize_admin!
    token = ENV["ADMIN_TOKEN"]
    return render_unauthorized if token.blank?

    provided = params[:token] || request.headers["X-Admin-Token"]
    unless provided.present? && ActiveSupport::SecurityUtils.secure_compare(provided.to_s, token)
      render_unauthorized
    end
  end

  def render_unauthorized
    render plain: "Unauthorized", status: :unauthorized
  end
end
