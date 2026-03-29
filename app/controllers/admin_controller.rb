class AdminController < ActionController::Base
  before_action :authorize_admin!
  skip_before_action :verify_authenticity_token, raise: false

  def dashboard
    @stats = {
      total_users: (User.count rescue 0),
      users_with_images: (User.joins("INNER JOIN active_storage_attachments ON active_storage_attachments.record_id = users.id AND active_storage_attachments.record_type = 'User' AND active_storage_attachments.name = 'profile_image'").distinct.count rescue 0),
      active_shame: (User.where(shame_active: true).count rescue 0),
      total_sessions: (FocusSession.count rescue 0),
      failed_sessions: (FocusSession.where(status: 'failed').count rescue 0),
      completed_sessions: (FocusSession.where(status: 'completed').count rescue 0),
      unresolved_reports: (Report.where(resolved: false).count rescue 0),
      unread_contacts: (Contact.where(read: false).count rescue 0)
    }
    @users = User.order(created_at: :desc).limit(50) rescue []
    @recent_sessions = FocusSession.includes(:user).order(created_at: :desc).limit(20) rescue []
    @reports = Report.order(created_at: :desc).limit(20) rescue []
    @contacts = Contact.order(created_at: :desc).limit(20) rescue []

    render :dashboard, layout: false
  rescue => e
    render plain: "Dashboard error: #{e.message}\n#{e.backtrace.first(5).join("\n")}", status: :internal_server_error
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
