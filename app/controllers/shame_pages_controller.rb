require "net/http"

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

  # POST /p/:slug/report
  def report
    report = Report.new(
      page_slug: params[:slug],
      reason: params[:reason],
      details: params[:details],
      reporter_ip: request.remote_ip
    )

    if report.save
      send_report_telegram_notification(report)
      render json: { message: "Report submitted. Thank you." }, status: :created
    else
      render json: { errors: report.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /p/:slug/watch
  def watch
    unless User.exists?(page_slug: params[:slug])
      render json: { error: "Page not found" }, status: :not_found
      return
    end

    watcher = PageWatcher.new(
      page_slug: params[:slug],
      email: params[:email]
    )

    if watcher.save
      Thread.new { WatcherNotificationService.send_welcome(watcher) }
      render json: { message: "You'll be notified when this page changes." }, status: :created
    else
      if watcher.errors[:email]&.include?("is already watching this page")
        render json: { message: "You're already watching this page." }, status: :ok
      else
        render json: { errors: watcher.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  # GET /unsubscribe/:token
  def unsubscribe
    watcher = PageWatcher.find_by(unsubscribe_token: params[:token])

    if watcher
      watcher.destroy
      render html: unsubscribe_success_html.html_safe
    else
      render html: "<p>Link expired or already unsubscribed.</p>".html_safe, status: :not_found
    end
  end

  # GET /admin/reports
  def reports_index
    render json: { error: "Unauthorized" }, status: :unauthorized and return unless admin_authorized?

    reports = Report.recent
    render json: reports
  end

  private

  def admin_authorized?
    token = ENV["ADMIN_TOKEN"]
    return false if token.blank?

    ActiveSupport::SecurityUtils.secure_compare(
      request.headers["X-Admin-Token"].to_s,
      token
    )
  end

  def send_report_telegram_notification(report)
    return unless ENV["TELEGRAM_BOT_TOKEN"].present? && ENV["TELEGRAM_CHAT_ID"].present?

    message = <<~MSG
      🚨 Content Report

      Page: /p/#{report.page_slug}
      Reason: #{report.reason}
      Details: #{report.details.presence || "None"}
      IP: #{report.reporter_ip}
      Time: #{report.created_at.strftime("%Y-%m-%d %H:%M UTC")}
    MSG

    uri = URI("https://api.telegram.org/bot#{ENV["TELEGRAM_BOT_TOKEN"]}/sendMessage")
    Net::HTTP.post_form(uri, chat_id: ENV["TELEGRAM_CHAT_ID"], text: message)
  rescue StandardError => e
    Rails.logger.error("Telegram report notification failed: #{e.message}")
  end

  def unsubscribe_success_html
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Unsubscribed - Blackmail.wtf</title>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { font-family: 'Avenir Next', sans-serif; background: #120f0e; color: #f9fafb; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
          .card { text-align: center; padding: 3rem; }
          h1 { color: #4f9bc4; font-size: 1.5rem; margin-bottom: 1rem; }
          p { opacity: 0.7; margin-bottom: 2rem; }
          a { color: #4f9bc4; text-decoration: none; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>Unsubscribed</h1>
          <p>You won't receive any more notifications for this page.</p>
          <a href="/">Back to Blackmail.wtf</a>
        </div>
      </body>
      </html>
    HTML
  end
end
