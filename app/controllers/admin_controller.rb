require "net/http"
require "json"

class AdminController < ActionController::Base
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authorize_admin!, except: [:login, :authenticate]

  TURNSTILE_SITE_KEY = "0x4AAAAAACxvDpu0x1EF7msb"

  # GET /admin/login
  def login
    render html: login_html.html_safe, layout: false
  end

  # POST /admin/authenticate
  def authenticate
    turnstile_token = params["cf-turnstile-response"]
    unless verify_turnstile(turnstile_token)
      return render html: login_html("Captcha verification failed").html_safe, layout: false, status: :forbidden
    end

    token = ENV["ADMIN_TOKEN"]
    if token.present? && ActiveSupport::SecurityUtils.secure_compare(params[:token].to_s, token)
      session[:admin_authenticated] = true
      redirect_to admin_path
    else
      render html: login_html("Invalid token").html_safe, layout: false, status: :unauthorized
    end
  end

  # GET /admin
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
    render plain: "Dashboard error: #{e.message}", status: :internal_server_error
  end

  # POST /admin/users/:id/deactivate_shame
  def deactivate_shame
    user = User.find(params[:id])
    user.deactivate_shame!
    redirect_to admin_path, notice: "Shame deactivated for #{user.username}"
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_path, alert: "User not found"
  end

  # DELETE /admin/users/:id
  def delete_user
    user = User.find(params[:id])
    username = user.username
    user.profile_image.purge if user.profile_image.attached?
    user.focus_sessions.destroy_all
    user.app_attest_credentials.destroy_all
    user.destroy!
    redirect_to admin_path, notice: "User #{username} deleted"
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_path, alert: "User not found"
  end

  # POST /admin/reports/:id/resolve
  def resolve_report
    report = Report.find(params[:id])
    report.update!(resolved: true)
    redirect_to admin_path, notice: "Report resolved"
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_path, alert: "Report not found"
  end

  # POST /admin/contacts/:id/read
  def mark_contact_read
    contact = Contact.find(params[:id])
    contact.update!(read: true)
    redirect_to admin_path, notice: "Contact marked as read"
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_path, alert: "Contact not found"
  end

  private

  def authorize_admin!
    unless session[:admin_authenticated]
      redirect_to admin_login_path
    end
  end

  def verify_turnstile(token)
    return false if token.blank?

    secret = ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"]
    return true if secret.blank? # Skip if not configured

    uri = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify")
    response = Net::HTTP.post_form(uri, secret: secret, response: token, remoteip: request.remote_ip)
    result = JSON.parse(response.body)
    result["success"] == true
  rescue StandardError
    false
  end

  def login_html(error = nil)
    error_html = error ? "<p style='color:#e5332a;margin-bottom:1rem;'>#{error}</p>" : ""
    <<~HTML
      <!DOCTYPE html>
      <html><head>
        <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Login - Blackmail</title>
        <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
        <style>
          * { margin:0; padding:0; box-sizing:border-box; }
          body { font-family:-apple-system,sans-serif; background:#0a0a0a; color:#e5e5e5; display:flex; align-items:center; justify-content:center; min-height:100vh; }
          .card { background:#1a1a1a; border-radius:12px; padding:2rem; max-width:360px; width:100%; }
          h1 { color:#4f9bc4; font-size:1.2rem; margin-bottom:1.5rem; text-align:center; }
          input { width:100%; padding:0.75rem; border:1px solid #333; border-radius:8px; background:#0a0a0a; color:#e5e5e5; font-size:1rem; margin-bottom:1rem; }
          input:focus { outline:none; border-color:#4f9bc4; }
          button { width:100%; padding:0.75rem; border:none; border-radius:8px; background:#4f9bc4; color:#fff; font-weight:600; font-size:1rem; cursor:pointer; margin-top:0.5rem; }
          button:hover { opacity:0.9; }
          .cf-turnstile { margin-bottom:1rem; }
        </style>
      </head><body>
        <div class="card">
          <h1>BLACKMAIL Admin</h1>
          #{error_html}
          <form method="POST" action="/admin/authenticate">
            <input type="password" name="token" placeholder="Admin Token" required autofocus>
            <div class="cf-turnstile" data-sitekey="#{TURNSTILE_SITE_KEY}" data-theme="dark"></div>
            <button type="submit">Login</button>
          </form>
        </div>
      </body></html>
    HTML
  end
end
