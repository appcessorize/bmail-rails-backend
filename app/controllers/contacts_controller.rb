require "net/http"

class ContactsController < ActionController::Base
  # GET /contact
  def new
    render html: contact_form_html.html_safe
  end

  # POST /contact
  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      send_telegram_notification(@contact)
      render html: success_page_html.html_safe
    else
      render html: contact_form_html(@contact.errors.full_messages).html_safe, status: :unprocessable_entity
    end
  end

  # GET /admin/contacts (protected - add your own auth)
  def index
    # Simple protection - in production, add proper admin auth
    render json: { error: "Unauthorized" }, status: :unauthorized and return unless admin_authorized?

    @contacts = Contact.recent
    render json: @contacts
  end

  private

  def contact_params
    params.permit(:email, :message)
  end

  def send_telegram_notification(contact)
    return unless telegram_configured?

    bot_token = ENV["TELEGRAM_BOT_TOKEN"]
    chat_id = ENV["TELEGRAM_CHAT_ID"]

    message = <<~MSG
      📬 New Contact Form Submission

      From: #{contact.email}
      Time: #{contact.created_at.strftime("%Y-%m-%d %H:%M UTC")}

      Message:
      #{contact.message}
    MSG

    uri = URI("https://api.telegram.org/bot#{bot_token}/sendMessage")
    Net::HTTP.post_form(uri, chat_id: chat_id, text: message, parse_mode: "HTML")
  rescue StandardError => e
    Rails.logger.error("Telegram notification failed: #{e.message}")
  end

  def telegram_configured?
    ENV["TELEGRAM_BOT_TOKEN"].present? && ENV["TELEGRAM_CHAT_ID"].present?
  end

  def admin_authorized?
    # Check for admin token in header
    request.headers["X-Admin-Token"] == ENV.fetch("ADMIN_TOKEN", "change-me-in-production")
  end

  def colors
    {
      red: '#e5332a',
      blue: '#4f9bc4',
      cream: '#f9fafb',
      dark: '#120f0e',
      pink: '#ffbfd9'
    }
  end

  def shared_styles
    <<~CSS
      <style>
        @font-face {
          font-family: 'WhirlyBirdie';
          src: url('/fonts/WhirlyBirdie-WideBold.otf') format('opentype');
          font-weight: bold;
          font-style: normal;
          font-display: swap;
        }
        :root {
          --bm-red: #{colors[:red]};
          --bm-blue: #{colors[:blue]};
          --bm-cream: #{colors[:cream]};
          --bm-dark: #{colors[:dark]};
          --bm-pink: #{colors[:pink]};
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: 'Avenir Next', Avenir, Montserrat, Corbel, 'URW Gothic', source-sans-pro, sans-serif;
          line-height: 1.7;
          background: var(--bm-dark);
          color: var(--bm-cream);
          min-height: 100vh;
        }
        .container { max-width: 600px; margin: 0 auto; padding: 0 20px; }
      </style>
    CSS
  end

  def contact_form_html(errors = [])
    error_html = if errors.any?
      "<div class='error-box'>#{errors.map { |e| "<p>#{e}</p>" }.join}</div>"
    else
      ""
    end

    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Contact Us - Blackmail.wtf</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📵</text></svg>">
        #{shared_styles}
        <style>
          header {
            padding: 20px 0;
            border-bottom: 2px solid var(--bm-blue);
            margin-bottom: 60px;
          }
          .header-inner {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 600px;
            margin: 0 auto;
            padding: 0 20px;
          }
          .back-link {
            color: var(--bm-blue);
            text-decoration: none;
            font-size: 1rem;
          }
          .back-link:hover { color: var(--bm-cream); }
          h1 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            font-size: 2.5rem;
            color: var(--bm-red);
            text-align: center;
            margin-bottom: 1rem;
            letter-spacing: 2px;
          }
          .subtitle {
            text-align: center;
            color: var(--bm-cream);
            opacity: 0.8;
            margin-bottom: 3rem;
          }
          .contact-form {
            background: rgba(79, 155, 196, 0.1);
            border: 1px solid var(--bm-blue);
            border-radius: 16px;
            padding: 2rem;
          }
          .form-group {
            margin-bottom: 1.5rem;
          }
          label {
            display: block;
            color: var(--bm-blue);
            font-weight: 600;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
          }
          input, textarea {
            width: 100%;
            padding: 1rem;
            border: 2px solid rgba(79, 155, 196, 0.3);
            border-radius: 8px;
            background: var(--bm-dark);
            color: var(--bm-cream);
            font-size: 1rem;
            font-family: inherit;
            transition: border-color 0.2s;
          }
          input:focus, textarea:focus {
            outline: none;
            border-color: var(--bm-blue);
          }
          textarea {
            min-height: 150px;
            resize: vertical;
          }
          .submit-btn {
            width: 100%;
            padding: 1rem 2rem;
            background: var(--bm-red);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
          }
          .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(229, 51, 42, 0.4);
          }
          .submit-btn:disabled {
            opacity: 0.7;
            cursor: not-allowed;
            transform: none;
          }
          .submit-btn .spinner {
            display: none;
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
          }
          .submit-btn.loading .spinner {
            display: inline-block;
          }
          .submit-btn.loading .btn-text {
            display: none;
          }
          @keyframes spin {
            to { transform: rotate(360deg); }
          }
          .error-box {
            background: rgba(229, 51, 42, 0.2);
            border: 1px solid var(--bm-red);
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1.5rem;
          }
          .error-box p {
            color: var(--bm-red);
            margin: 0.25rem 0;
            font-size: 0.9rem;
          }
          footer {
            text-align: center;
            padding: 3rem 0;
            color: var(--bm-cream);
            opacity: 0.6;
            font-size: 0.9rem;
          }
          footer a {
            color: var(--bm-blue);
            text-decoration: none;
          }
        </style>
      </head>
      <body>
        <header>
          <div class="header-inner">
            <a href="/" class="back-link">← Back</a>
            <span style="color: var(--bm-blue); font-weight: 600;">BLACKMAIL</span>
          </div>
        </header>

        <div class="container">
          <h1>Get in Touch</h1>
          <p class="subtitle">Have a question or feedback? We'd love to hear from you.<br>We'll get back to you the same day.</p>

          <form class="contact-form" action="/contact" method="POST" id="contactForm">
            #{error_html}
            <div class="form-group">
              <label for="email">Your Email</label>
              <input type="email" id="email" name="email" placeholder="you@example.com" required>
            </div>
            <div class="form-group">
              <label for="message">Your Message</label>
              <textarea id="message" name="message" placeholder="Your message..." required minlength="10" maxlength="5000"></textarea>
            </div>
            <button type="submit" class="submit-btn" id="submitBtn">
              <span class="btn-text">Send Message ✈</span>
              <span class="spinner"></span>
            </button>
          </form>
        </div>

        <footer>
          <p>&copy; 2025 Blackmail.wtf &bull; <a href="/privacy">Privacy</a> &bull; <a href="/terms">Terms</a></p>
        </footer>

        <script>
          document.getElementById('contactForm').addEventListener('submit', function() {
            var btn = document.getElementById('submitBtn');
            btn.classList.add('loading');
            btn.disabled = true;
          });
        </script>
      </body>
      </html>
    HTML
  end

  def success_page_html
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Message Sent - Blackmail.wtf</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📵</text></svg>">
        #{shared_styles}
        <style>
          .success-container {
            text-align: center;
            padding: 100px 20px;
          }
          .success-icon {
            font-size: 5rem;
            margin-bottom: 2rem;
          }
          h1 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            font-size: 2.5rem;
            color: var(--bm-blue);
            margin-bottom: 1rem;
            letter-spacing: 2px;
          }
          p {
            color: var(--bm-cream);
            opacity: 0.8;
            margin-bottom: 2rem;
            font-size: 1.1rem;
          }
          .back-btn {
            display: inline-block;
            padding: 1rem 2rem;
            background: var(--bm-blue);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            transition: transform 0.2s;
          }
          .back-btn:hover {
            transform: translateY(-2px);
          }
        </style>
      </head>
      <body>
        <div class="success-container">
          <div class="success-icon">✈️</div>
          <h1>Thank You!</h1>
          <p>Your message has been sent successfully.<br>We'll get back to you the same day.</p>
          <a href="/" class="back-btn">Back to Home</a>
        </div>
      </body>
      </html>
    HTML
  end
end
