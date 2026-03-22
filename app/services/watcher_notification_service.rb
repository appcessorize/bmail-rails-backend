class WatcherNotificationService
  FROM_EMAIL = "Blackmail.wtf <notifications@updates.blackmail.wtf>"

  def self.notify_watchers(user)
    return unless ENV["RESEND_API_KEY"].present?
    return unless user.page_slug.present?

    watchers = PageWatcher.for_slug(user.page_slug)
    return if watchers.none?

    page_url = "#{ENV.fetch("PUBLIC_BASE_URL", "https://blackmail.wtf")}/p/#{user.page_slug}"

    watchers.find_each do |watcher|
      send_notification(watcher, page_url)
    rescue StandardError => e
      Rails.logger.error("Watcher notification failed for watcher ##{watcher.id}: #{e.message}")
    end
  end

  def self.send_welcome(watcher)
    return unless ENV["RESEND_API_KEY"].present?

    page_url = "#{ENV.fetch("PUBLIC_BASE_URL", "https://blackmail.wtf")}/p/#{watcher.page_slug}"
    unsubscribe_url = "#{ENV.fetch("PUBLIC_BASE_URL", "https://blackmail.wtf")}/unsubscribe/#{watcher.unsubscribe_token}"
    app_url = "https://apps.apple.com/app/blackmail-focus-or-else/id6745029022"

    Resend::Emails.send({
      from: FROM_EMAIL,
      to: watcher.email,
      subject: "You're watching a Blackmail page",
      html: welcome_html(page_url, unsubscribe_url, app_url)
    })
  rescue StandardError => e
    Rails.logger.error("Welcome email failed for watcher ##{watcher.id}: #{e.message}")
  end

  private

  def self.send_notification(watcher, page_url)
    unsubscribe_url = "#{ENV.fetch("PUBLIC_BASE_URL", "https://blackmail.wtf")}/unsubscribe/#{watcher.unsubscribe_token}"

    Resend::Emails.send({
      from: FROM_EMAIL,
      to: watcher.email,
      subject: "SHAME! They failed their focus session",
      html: notification_html(page_url, unsubscribe_url)
    })
  end

  def self.notification_html(page_url, unsubscribe_url)
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="margin:0; padding:0; background:#120f0e; font-family:'Avenir Next',Avenir,Helvetica,Arial,sans-serif;">
        <table width="100%" cellpadding="0" cellspacing="0" style="background:#120f0e; padding:40px 20px;">
          <tr>
            <td align="center">
              <table width="480" cellpadding="0" cellspacing="0" style="max-width:480px; width:100%;">
                <!-- Header -->
                <tr>
                  <td style="padding-bottom:30px; border-bottom:2px solid #4f9bc4;">
                    <span style="color:#e5332a; font-size:24px; font-weight:bold; letter-spacing:2px;">BLACKMAIL</span>
                  </td>
                </tr>

                <!-- Content -->
                <tr>
                  <td style="padding:40px 0; text-align:center;">
                    <div style="background:#e5332a; color:#fff; display:inline-block; padding:8px 24px; border-radius:99px; font-size:14px; font-weight:700; letter-spacing:2px; text-transform:uppercase; margin-bottom:20px;">
                      FAILED
                    </div>
                    <h1 style="color:#e5332a; font-size:32px; font-weight:bold; margin:20px 0 12px; line-height:1.2;">
                      THEY COULDN'T RESIST
                    </h1>
                    <p style="color:#f9fafb; opacity:0.7; font-size:16px; margin:0 0 30px; line-height:1.6;">
                      Someone you're watching just failed their focus session. Their embarrassing photo is now live.
                    </p>
                    <a href="#{page_url}" style="display:inline-block; background:#e5332a; color:#fff; padding:14px 32px; border-radius:12px; font-weight:700; font-size:16px; text-decoration:none;">
                      View the Shame Page
                    </a>
                  </td>
                </tr>

                <!-- Footer -->
                <tr>
                  <td style="padding-top:30px; border-top:2px solid rgba(79,155,196,0.3); text-align:center;">
                    <p style="color:rgba(79,155,196,0.5); font-size:12px; margin:0 0 8px;">
                      You're receiving this because you subscribed to updates for this shame page.
                    </p>
                    <a href="#{unsubscribe_url}" style="color:#4f9bc4; font-size:12px; text-decoration:none;">
                      Unsubscribe
                    </a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
      </html>
    HTML
  end

  def self.welcome_html(page_url, unsubscribe_url, app_url)
    <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="margin:0; padding:0; background:#120f0e; font-family:'Avenir Next',Avenir,Helvetica,Arial,sans-serif;">
        <table width="100%" cellpadding="0" cellspacing="0" style="background:#120f0e; padding:40px 20px;">
          <tr>
            <td align="center">
              <table width="480" cellpadding="0" cellspacing="0" style="max-width:480px; width:100%;">
                <tr>
                  <td style="padding-bottom:30px; border-bottom:2px solid #4f9bc4;">
                    <span style="color:#e5332a; font-size:24px; font-weight:bold; letter-spacing:2px;">BLACKMAIL</span>
                  </td>
                </tr>

                <tr>
                  <td style="padding:40px 0; text-align:center;">
                    <h1 style="color:#f9fafb; font-size:28px; font-weight:bold; margin:0 0 16px; line-height:1.3;">
                      You're watching a shame page
                    </h1>
                    <p style="color:#f9fafb; opacity:0.7; font-size:16px; margin:0 0 12px; line-height:1.7;">
                      Someone shared their Blackmail page with you. When they fail a focus session by picking up their phone, their embarrassing photo will go live — and you'll be the first to know.
                    </p>
                    <p style="color:#f9fafb; opacity:0.7; font-size:16px; margin:0 0 30px; line-height:1.7;">
                      We'll send you an email the moment it happens.
                    </p>
                    <a href="#{page_url}" style="display:inline-block; background:#4f9bc4; color:#fff; padding:14px 32px; border-radius:12px; font-weight:700; font-size:16px; text-decoration:none;">
                      View the Page
                    </a>
                  </td>
                </tr>

                <tr>
                  <td style="padding:30px 0; border-top:1px solid rgba(79,155,196,0.2); text-align:center;">
                    <p style="color:#f9fafb; font-size:18px; font-weight:700; margin:0 0 8px;">
                      Want to blackmail yourself?
                    </p>
                    <p style="color:#f9fafb; opacity:0.6; font-size:14px; margin:0 0 20px; line-height:1.6;">
                      Blackmail is a free app that uses the power of shame to help you put your phone down. Upload an embarrassing photo, share your page, and stay focused — or face the consequences.
                    </p>
                    <a href="#{app_url}" style="display:inline-block; background:#e5332a; color:#fff; padding:14px 32px; border-radius:12px; font-weight:700; font-size:16px; text-decoration:none;">
                      Download Blackmail
                    </a>
                  </td>
                </tr>

                <tr>
                  <td style="padding-top:30px; border-top:1px solid rgba(79,155,196,0.15); text-align:center;">
                    <p style="color:rgba(79,155,196,0.5); font-size:12px; margin:0 0 8px;">
                      You're receiving this because you subscribed to updates for a shame page on Blackmail.wtf
                    </p>
                    <a href="#{unsubscribe_url}" style="color:#4f9bc4; font-size:12px; text-decoration:none;">
                      Unsubscribe
                    </a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </body>
      </html>
    HTML
  end
end
