class PagesController < ActionController::Base
  def home
    render html: landing_page_html.html_safe
  end

  def privacy
    render html: privacy_policy_html.html_safe
  end

  def terms
    render html: terms_of_service_html.html_safe
  end

  private

  def landing_page_html
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Blackmail.wtf - Freedom from Your Phone</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📵</text></svg>">
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          body {
            font-family: Georgia, 'Times New Roman', serif;
            background: #120f0e;
            color: #f9fafb;
            min-height: 100vh;
            padding: 20px;
          }
          .container {
            max-width: 800px;
            margin: 0 auto;
          }
          header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 0;
            border-bottom: 2px solid #4f9bc4;
            margin-bottom: 40px;
          }
          .logo {
            text-decoration: none;
          }
          .logo img {
            height: 40px;
            width: auto;
          }
          h1 {
            font-size: 3.5rem;
            font-weight: 900;
            color: #e5332a;
            margin-bottom: 2rem;
            text-align: center;
            line-height: 1.1;
          }
          .tagline {
            font-size: 1.5rem;
            margin-bottom: 3rem;
            text-align: center;
            color: #4f9bc4;
            font-weight: bold;
          }
          .content {
            font-size: 1.1rem;
            line-height: 1.8;
            margin-bottom: 2rem;
          }
          .highlight {
            color: #e5332a;
            font-weight: bold;
            font-style: italic;
          }
          .cta-section {
            text-align: center;
            margin: 4rem 0;
            padding: 3rem;
            background: #f9fafb;
            border-radius: 16px;
          }
          .cta {
            display: inline-block;
            background: #e5332a;
            color: white;
            padding: 1.2rem 3rem;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.3rem;
            transition: transform 0.2s, box-shadow 0.2s;
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
          }
          .cta:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(229, 51, 42, 0.4);
          }
          .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            margin: 3rem 0;
          }
          .feature {
            background: rgba(79, 155, 196, 0.1);
            padding: 2rem;
            border-radius: 12px;
            border: 2px solid #4f9bc4;
          }
          .feature h3 {
            font-size: 1.3rem;
            margin-bottom: 0.8rem;
            color: #4f9bc4;
          }
          footer {
            text-align: center;
            margin-top: 4rem;
            padding-top: 2rem;
            border-top: 2px solid #4f9bc4;
            color: #4f9bc4;
            font-size: 0.9rem;
          }
          @media (max-width: 768px) {
            h1 {
              font-size: 2.5rem;
            }
            .tagline {
              font-size: 1.2rem;
            }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <header>
            <a href="/" class="logo">
              <img src="/images/BLACKMAILShadow.png" alt="BLACKMAIL">
            </a>
            <nav style="color: #4f9bc4; font-size: 1.5rem; width: 32px; height: 32px; border: 2px solid #4f9bc4; border-radius: 50%; display: flex; align-items: center; justify-content: center;">?</nav>
          </header>

          <h1>No One is Bored,<br>Everything is Boring</h1>

          <p class="tagline">FREEDOM FROM YOUR PHONE</p>

          <div class="content">
            <p>Right now some of the world's most talented people are working overtime to stop you from putting down your phone.</p>
            <p>The apps on your phone don't care about your wellbeing. Their purpose is to improve an abstract metric linked to a stranger's performance related bonus.</p>
            <p><strong>Blackmail</strong> helps you create a small space where you can be free from your phone.</p>
            <p>Fighting the modern psychological tactics of nudges and incentives is simple when you use the oldest motivational strategy:</p>
            <p class="highlight" style="font-size: 2rem; text-align: center; margin: 2rem 0;">SHAME</p>
          </div>

          <div class="cta-section">
            <h2 style="color: #120f0e; margin-bottom: 1rem; font-size: 2rem;">How It Works</h2>
            <div class="features" style="margin-bottom: 2rem;">
              <div class="feature" style="background: white; border-color: #e5332a;">
                <h3 style="color: #e5332a;">📸 Take Photo</h3>
                <p style="color: #120f0e;">Upload an embarrassing selfie</p>
              </div>
              <div class="feature" style="background: white; border-color: #e5332a;">
                <h3 style="color: #e5332a;">⏰ Set Timer</h3>
                <p style="color: #120f0e;">Choose your focus duration</p>
              </div>
              <div class="feature" style="background: white; border-color: #e5332a;">
                <h3 style="color: #e5332a;">📱 Stay Focused</h3>
                <p style="color: #120f0e;">Put your phone face down</p>
              </div>
            </div>
            <a href="#" class="cta">Download for iOS (Coming Soon)</a>
          </div>

          <footer>
            <p>On your deathbed, do you think you will regret not using your phone more?</p>
            <p style="margin-top: 1rem;">© 2025 Blackmail.wtf</p>
            <p style="margin-top: 0.5rem;">
              <a href="/privacy" style="color: #4f9bc4; text-decoration: none;">Privacy Policy</a>
              &nbsp;•&nbsp;
              <a href="/terms" style="color: #4f9bc4; text-decoration: none;">Terms of Service</a>
            </p>
          </footer>
        </div>
      </body>
      </html>
    HTML
  end

  def privacy_policy_html
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Privacy Policy - Blackmail.wtf</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📵</text></svg>">
        #{legal_page_styles}
      </head>
      <body>
        <div class="container">
          <a href="/" class="back-link">← Back to Home</a>
          <h1>Privacy Policy</h1>
          <p class="updated">Last updated: January 2025</p>

          <section>
            <h2>1. Information We Collect</h2>
            <p>We collect the following information when you use Blackmail.wtf:</p>
            <ul>
              <li><strong>Account Information:</strong> Username, email address (optional), and authentication credentials.</li>
              <li><strong>Profile Images:</strong> Photos you voluntarily upload for use with the shame feature.</li>
              <li><strong>Usage Data:</strong> Focus session history, including start times, durations, and completion status.</li>
            </ul>
          </section>

          <section>
            <h2>2. How We Use Your Information</h2>
            <p>We use your information to:</p>
            <ul>
              <li>Provide and operate the Blackmail.wtf service</li>
              <li>Display your shame page when you fail a focus session (only if you have uploaded a photo)</li>
              <li>Track your focus session history</li>
              <li>Improve and maintain our service</li>
            </ul>
          </section>

          <section>
            <h2>3. Information Sharing</h2>
            <p>We do not sell, trade, or rent your personal information to third parties. Your profile image is only displayed on your unique shame page URL when shame is active, and only to those who have your specific page link.</p>
          </section>

          <section>
            <h2>4. Data Security</h2>
            <p>We implement reasonable security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.</p>
          </section>

          <section>
            <h2>5. Your Rights</h2>
            <p>You can:</p>
            <ul>
              <li>Delete your profile image at any time</li>
              <li>Hide your shame image from your public page</li>
              <li>Request deletion of your account by contacting us</li>
            </ul>
          </section>

          <section>
            <h2>6. Contact Us</h2>
            <p>For privacy-related questions, contact us at: <a href="mailto:support@blackmail.wtf">support@blackmail.wtf</a></p>
          </section>
        </div>
      </body>
      </html>
    HTML
  end

  def terms_of_service_html
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Terms of Service - Blackmail.wtf</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📵</text></svg>">
        #{legal_page_styles}
      </head>
      <body>
        <div class="container">
          <a href="/" class="back-link">← Back to Home</a>
          <h1>Terms of Service</h1>
          <p class="updated">Last updated: January 2025</p>

          <section>
            <h2>1. Acceptance of Terms</h2>
            <p>By accessing or using Blackmail.wtf, you agree to be bound by these Terms of Service. If you do not agree, do not use our service.</p>
          </section>

          <section>
            <h2>2. Description of Service</h2>
            <p>Blackmail.wtf is a focus and productivity app that uses social accountability to help you stay off your phone. You upload a photo that may be displayed on a public page if you fail to complete a focus session.</p>
          </section>

          <section>
            <h2>3. User Responsibilities</h2>
            <p>You agree to:</p>
            <ul>
              <li>Only upload images of yourself that you have the right to share</li>
              <li>Not upload illegal, harmful, or inappropriate content</li>
              <li>Not use the service for any unlawful purpose</li>
              <li>Keep your account credentials secure</li>
            </ul>
          </section>

          <section>
            <h2>4. Content Ownership</h2>
            <p>You retain ownership of any images you upload. By uploading content, you grant us a license to display that content as part of the service (i.e., on your shame page when applicable).</p>
          </section>

          <section>
            <h2>5. Disclaimer</h2>
            <p>The service is provided "as is" without warranties of any kind. We are not responsible for any embarrassment, social consequences, or other outcomes resulting from your use of the service.</p>
          </section>

          <section>
            <h2>6. Limitation of Liability</h2>
            <p>To the maximum extent permitted by law, Blackmail.wtf shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the service.</p>
          </section>

          <section>
            <h2>7. Termination</h2>
            <p>We reserve the right to terminate or suspend your account at any time for violations of these terms or for any other reason at our discretion.</p>
          </section>

          <section>
            <h2>8. Changes to Terms</h2>
            <p>We may update these terms from time to time. Continued use of the service after changes constitutes acceptance of the new terms.</p>
          </section>

          <section>
            <h2>9. Contact</h2>
            <p>Questions about these terms? Contact us at: <a href="mailto:support@blackmail.wtf">support@blackmail.wtf</a></p>
          </section>
        </div>
      </body>
      </html>
    HTML
  end

  def legal_page_styles
    <<~CSS
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: Georgia, 'Times New Roman', serif;
          background: #120f0e;
          color: #f9fafb;
          min-height: 100vh;
          padding: 20px;
          line-height: 1.7;
        }
        .container { max-width: 800px; margin: 0 auto; }
        .back-link {
          display: inline-block;
          color: #4f9bc4;
          text-decoration: none;
          margin-bottom: 2rem;
          font-size: 1rem;
        }
        .back-link:hover { text-decoration: underline; }
        h1 {
          font-size: 2.5rem;
          color: #e5332a;
          margin-bottom: 0.5rem;
        }
        .updated {
          color: #888;
          margin-bottom: 2rem;
          font-style: italic;
        }
        section {
          margin-bottom: 2rem;
          padding: 1.5rem;
          background: rgba(79, 155, 196, 0.05);
          border-radius: 8px;
          border-left: 3px solid #4f9bc4;
        }
        h2 {
          color: #4f9bc4;
          font-size: 1.3rem;
          margin-bottom: 1rem;
        }
        p { margin-bottom: 1rem; }
        ul {
          margin-left: 1.5rem;
          margin-bottom: 1rem;
        }
        li { margin-bottom: 0.5rem; }
        a { color: #4f9bc4; }
        a:hover { color: #6fb5d8; }
        @media (max-width: 768px) {
          h1 { font-size: 2rem; }
        }
      </style>
    CSS
  end
end
