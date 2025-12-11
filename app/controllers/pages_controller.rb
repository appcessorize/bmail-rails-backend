class PagesController < ActionController::Base
  def home
    render html: landing_page_html.html_safe
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
          </footer>
        </div>
      </body>
      </html>
    HTML
  end
end
