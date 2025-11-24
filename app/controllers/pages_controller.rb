class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

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
        <title>Blackmail.wtf - Focus or Face the Consequences</title>
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
          }
          .container {
            max-width: 800px;
            text-align: center;
          }
          h1 {
            font-size: 4rem;
            font-weight: 900;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
          }
          .tagline {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            opacity: 0.9;
          }
          .description {
            font-size: 1.2rem;
            line-height: 1.6;
            margin-bottom: 3rem;
            opacity: 0.85;
          }
          .cta {
            display: inline-block;
            background: white;
            color: #667eea;
            padding: 1rem 3rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.2rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
            transition: transform 0.2s, box-shadow 0.2s;
          }
          .cta:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,0,0,0.3);
          }
          .features {
            margin-top: 4rem;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
          }
          .feature {
            background: rgba(255,255,255,0.1);
            padding: 2rem;
            border-radius: 15px;
            backdrop-filter: blur(10px);
          }
          .feature h3 {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Blackmail.wtf</h1>
          <p class="tagline">Focus or Face the Consequences</p>
          <p class="description">
            The productivity app that keeps you accountable. Upload an embarrassing photo,
            set your focus timer, and stay on task—or your secret gets shared.
          </p>
          <a href="#" class="cta">Download on iOS (Coming Soon)</a>

          <div class="features">
            <div class="feature">
              <h3>⏰ Set Timers</h3>
              <p>Focus for as long as you need</p>
            </div>
            <div class="feature">
              <h3>📸 Upload Photo</h3>
              <p>Your motivation to stay focused</p>
            </div>
            <div class="feature">
              <h3>🔒 Stay Secure</h3>
              <p>Your photos are encrypted and private</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    HTML
  end
end
