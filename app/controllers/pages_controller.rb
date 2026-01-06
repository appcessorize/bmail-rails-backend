class PagesController < ActionController::Base
  def home
    render html: landing_page_html.html_safe
  end

  def manifesto
    render html: manifesto_page_html.html_safe
  end

  def press
    render html: press_kit_html.html_safe
  end

  def privacy
    render html: privacy_policy_html.html_safe
  end

  def terms
    render html: terms_of_service_html.html_safe
  end

  private

  # Shared colors from manifesto
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
        @font-face {
          font-family: 'Whirlybats';
          src: url('/fonts/WhirlybatsVariable.ttf') format('truetype');
          font-weight: normal;
          font-style: normal;
          font-display: swap;
        }
        :root {
          --bm-red: #{colors[:red]};
          --bm-blue: #{colors[:blue]};
          --bm-cream: #{colors[:cream]};
          --bm-dark: #{colors[:dark]};
          --bm-pink: #{colors[:pink]};
          --font-display: 'WhirlyBirdie', Georgia, serif;
          --font-body: 'Avenir Next', Avenir, Montserrat, Corbel, 'URW Gothic', source-sans-pro, sans-serif;
          --font-icons: 'Whirlybats', sans-serif;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: var(--font-body);
          line-height: 1.7;
        }
        .whirly-title {
          font-family: var(--font-display);
          font-weight: bold;
          letter-spacing: 1px;
        }
        .container { max-width: 900px; margin: 0 auto; padding: 0 20px; }
        .btn-primary {
          display: inline-block;
          background: var(--bm-red);
          color: white;
          padding: 1rem 2.5rem;
          border-radius: 12px;
          text-decoration: none;
          font-weight: 700;
          font-size: 1.1rem;
          transition: transform 0.2s, box-shadow 0.2s;
          font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        }
        .btn-primary:hover {
          transform: translateY(-2px);
          box-shadow: 0 6px 20px rgba(229, 51, 42, 0.4);
        }
        .btn-secondary {
          display: inline-block;
          background: transparent;
          color: var(--bm-blue);
          padding: 1rem 2.5rem;
          border: 2px solid var(--bm-blue);
          border-radius: 12px;
          text-decoration: none;
          font-weight: 700;
          font-size: 1.1rem;
          transition: all 0.2s;
          font-family: -apple-system, BlinkMacSystemFont, sans-serif;
        }
        .btn-secondary:hover {
          background: var(--bm-blue);
          color: white;
        }
      </style>
    CSS
  end

  def landing_page_html
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Blackmail.wtf - Freedom from Your Phone</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📵</text></svg>">
        <link rel="preload" href="/fonts/WhirlyBirdie-WideBold.otf" as="font" type="font/otf" crossorigin>
        #{shared_styles}
        <style>
          body {
            background: #fff;
            color: var(--bm-dark);
            min-height: 100vh;
          }
          .hero-wrapper {
            background: #fff;
          }
          header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 0;
            border-bottom: 2px solid var(--bm-blue);
          }
          .logo img { height: 40px; width: auto; }
          nav { display: flex; gap: 24px; align-items: center; }
          nav a {
            color: var(--bm-dark);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.95rem;
            transition: color 0.2s;
          }
          nav a:hover { color: var(--bm-red); }
          .hero {
            text-align: center;
            padding: 80px 0 60px;
          }
          h1 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            font-size: 4rem;
            font-weight: bold;
            color: var(--bm-red);
            margin-bottom: 1.5rem;
            line-height: 1.1;
            letter-spacing: 2px;
          }
          .tagline {
            font-family: 'WhirlyBirdie', Georgia, serif;
            font-size: 1.6rem;
            color: var(--bm-blue);
            font-weight: bold;
            margin-bottom: 2rem;
            letter-spacing: 1px;
          }
          .hero-text {
            font-size: 1.2rem;
            max-width: 600px;
            margin: 0 auto 2rem;
            color: var(--bm-dark);
            opacity: 0.85;
          }
          .shame-text {
            font-size: 3rem;
            color: var(--bm-red);
            font-weight: 900;
            font-style: italic;
            margin: 1.5rem 0 2.5rem;
          }
          .app-badge {
            height: 54px;
            width: auto;
            transition: transform 0.2s;
          }
          .app-badge:hover {
            transform: scale(1.05);
          }
          .how-it-works {
            background: #f5f5f7;
            color: var(--bm-dark);
            padding: 80px 0;
          }
          .how-it-works h2 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            text-align: center;
            font-size: 2.5rem;
            color: var(--bm-dark);
            margin-bottom: 3rem;
            letter-spacing: 1px;
          }
          .steps {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
          }
          .step {
            text-align: center;
            padding: 2rem;
          }
          .step-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
          }
          .step h3 {
            color: var(--bm-red);
            font-size: 1.3rem;
            margin-bottom: 0.8rem;
          }
          .step p { color: #555; }
          .faq-section {
            background: var(--bm-dark);
            padding: 80px 0;
          }
          .faq-section h2 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            text-align: center;
            color: var(--bm-blue);
            font-size: 2.5rem;
            margin-bottom: 1rem;
            letter-spacing: 1px;
          }
          .faq-subtitle {
            text-align: center;
            color: var(--bm-cream);
            opacity: 0.7;
            font-size: 1.1rem;
            margin-bottom: 3rem;
          }
          .faq-list {
            max-width: 800px;
            margin: 0 auto;
          }
          .faq-item {
            border-bottom: 1px solid rgba(79, 155, 196, 0.3);
          }
          .faq-item:first-child {
            border-top: 1px solid rgba(79, 155, 196, 0.3);
          }
          .faq-item summary {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.5rem 0;
            cursor: pointer;
            list-style: none;
            transition: all 0.2s ease;
          }
          .faq-item summary::-webkit-details-marker {
            display: none;
          }
          .faq-item summary::marker {
            display: none;
          }
          .faq-item summary:hover {
            padding-left: 10px;
          }
          .faq-item summary h3 {
            color: var(--bm-cream);
            font-size: 1.15rem;
            font-weight: 600;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
          }
          .faq-icon {
            font-size: 1.3rem;
          }
          .faq-arrow {
            color: var(--bm-blue);
            font-size: 1.5rem;
            font-weight: 300;
            transition: transform 0.3s ease;
            line-height: 1;
          }
          .faq-item[open] .faq-arrow {
            transform: rotate(180deg);
            color: var(--bm-red);
          }
          .faq-item[open] summary h3 {
            color: var(--bm-red);
          }
          .faq-answer {
            padding: 0 0 1.5rem 0;
            animation: fadeIn 0.3s ease;
          }
          @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
          }
          .faq-answer p {
            color: var(--bm-cream);
            opacity: 0.85;
            font-size: 1.05rem;
            line-height: 1.7;
            padding-left: 36px;
          }
          .cta-section {
            background: var(--bm-dark);
            padding: 80px 0;
            text-align: center;
          }
          .cta-section h2 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            color: var(--bm-cream);
            font-size: 2.5rem;
            margin-bottom: 1rem;
            letter-spacing: 1px;
          }
          .cta-section p {
            color: var(--bm-cream);
            opacity: 0.8;
            margin-bottom: 2.5rem;
            font-size: 1.2rem;
          }
          footer {
            background: #000;
            border-top: 2px solid var(--bm-blue);
            padding: 40px 0;
          }
          .footer-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 2rem;
          }
          .footer-section h4 {
            color: var(--bm-blue);
            font-size: 1rem;
            margin-bottom: 1rem;
            text-transform: uppercase;
            letter-spacing: 1px;
          }
          .footer-section a {
            display: block;
            color: var(--bm-cream);
            text-decoration: none;
            padding: 0.3rem 0;
            opacity: 0.8;
            transition: opacity 0.2s;
          }
          .footer-section a:hover { opacity: 1; }
          .footer-section p {
            color: var(--bm-cream);
            opacity: 0.7;
            font-size: 0.9rem;
          }
          .footer-bottom {
            text-align: center;
            margin-top: 3rem;
            padding-top: 2rem;
            border-top: 1px solid rgba(79, 155, 196, 0.3);
          }
          .footer-bottom p {
            color: var(--bm-blue);
            font-size: 0.9rem;
          }
          .quote {
            font-style: italic;
            color: var(--bm-cream);
            opacity: 0.8;
            margin-top: 1rem;
          }
          @media (max-width: 768px) {
            h1 { font-size: 2.5rem; }
            .tagline { font-size: 1.2rem; }
            .faq-question h3 { font-size: 1rem; }
            .faq-answer p { padding-left: 0; }
            nav { gap: 12px; }
            nav a { font-size: 0.85rem; }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <header>
            <a href="/" class="logo">
              <img src="/images/BLACKMAILShadow.png" alt="BLACKMAIL">
            </a>
            <nav>
              <a href="/manifesto">Manifesto</a>
              <a href="/press">Press Kit</a>
              <a href="#faq">FAQ</a>
            </nav>
          </header>
        </div>

        <div class="container">
          <section class="hero">
            <h1>No One is Bored,<br>Everything is Boring</h1>
            <p class="tagline">FREEDOM FROM YOUR PHONE</p>
            <p class="hero-text">
              Right now some of the world's most talented people are working overtime to stop you from putting down your phone.
              Fighting modern psychological manipulation is simple when you use the oldest motivational strategy:
            </p>
            <p class="shame-text">SHAME</p>
            <div style="display: flex; gap: 1.5rem; justify-content: center; align-items: center; flex-wrap: wrap;">
              <a href="https://apps.apple.com/app/blackmail-focus" target="_blank" rel="noopener">
                <img src="/images/appstorebadgeblack.svg" alt="Download on the App Store" class="app-badge">
              </a>
              <a href="/manifesto" class="btn-secondary">Read the Manifesto</a>
            </div>
          </section>
        </div>

        <section class="how-it-works">
          <div class="container">
            <h2>How It Works</h2>
            <div class="steps">
              <div class="step">
                <div class="step-icon">📸</div>
                <h3>Take an Embarrassing Selfie</h3>
                <p>Upload a photo you wouldn't want your friends to see. The more embarrassing, the more motivated you'll be.</p>
              </div>
              <div class="step">
                <div class="step-icon">🔗</div>
                <h3>Share Your Shame Page</h3>
                <p>Get a unique anonymous URL to share with friends. They'll check up on you to see if you failed.</p>
              </div>
              <div class="step">
                <div class="step-icon">⏰</div>
                <h3>Set a Focus Timer</h3>
                <p>Choose how long you want to stay focused. Put your phone face down and get to work.</p>
              </div>
              <div class="step">
                <div class="step-icon">😱</div>
                <h3>Face the Consequences</h3>
                <p>If you pick up your phone before the timer ends, your embarrassing photo goes live on your shame page.</p>
              </div>
            </div>
          </div>
        </section>

        <section class="faq-section" id="faq">
          <div class="container">
            <h2>Questions & Answers</h2>
            <p class="faq-subtitle">Everything you need to know about Blackmail Focus</p>
            <div class="faq-list">
              <details class="faq-item">
                <summary>
                  <h3><span class="faq-icon">📸</span> Is my photo really shared publicly?</h3>
                  <span class="faq-arrow">▼</span>
                </summary>
                <div class="faq-answer">
                  <p>Only if you fail! Your photo is stored securely and encrypted. It only appears on your unique shame page URL when you pick up your phone during a focus session. Think of it as a safety deposit box that only opens when you break your promise.</p>
                </div>
              </details>
              <details class="faq-item">
                <summary>
                  <h3><span class="faq-icon">🔍</span> Can anyone find my page?</h3>
                  <span class="faq-arrow">▼</span>
                </summary>
                <div class="faq-answer">
                  <p>No. Your page URL is a random 12-character code—like a secret password. There's no directory, no search, no way to browse. Only people you personally share the link with can ever see it.</p>
                </div>
              </details>
              <details class="faq-item">
                <summary>
                  <h3><span class="faq-icon">🗑️</span> Can I delete my photo?</h3>
                  <span class="faq-arrow">▼</span>
                </summary>
                <div class="faq-answer">
                  <p>Absolutely! You can delete your photo or hide it from your shame page anytime from the app settings. You're always in complete control. We believe in accountability, not hostage situations.</p>
                </div>
              </details>
              <details class="faq-item">
                <summary>
                  <h3><span class="faq-icon">🤔</span> Why would I do this to myself?</h3>
                  <span class="faq-arrow">▼</span>
                </summary>
                <div class="faq-answer">
                  <p>Because positive thinking doesn't work. The fear of embarrassment is hardwired into our brains—it's one of the most powerful motivators we have. By sharing your page with friends, you create real accountability that no amount of motivational quotes can match.</p>
                </div>
              </details>
              <details class="faq-item">
                <summary>
                  <h3><span class="faq-icon">🔒</span> Is my data secure?</h3>
                  <span class="faq-arrow">▼</span>
                </summary>
                <div class="faq-answer">
                  <p>Yes. Your photos are encrypted and stored securely on our servers. We never share your data with third parties, never use it for advertising, and never will. Your embarrassing photo is between you and your accountability partners—no one else.</p>
                </div>
              </details>
              <details class="faq-item">
                <summary>
                  <h3><span class="faq-icon">🏆</span> What if I complete my focus session?</h3>
                  <span class="faq-arrow">▼</span>
                </summary>
                <div class="faq-answer">
                  <p>Victory! Your photo stays private, and your shame page proudly shows that you're "Staying Strong" with no embarrassing photo visible. You get the satisfaction of keeping your dignity intact.</p>
                </div>
              </details>
              <details class="faq-item">
                <summary>
                  <h3><span class="faq-icon">💡</span> How is this different from other focus apps?</h3>
                  <span class="faq-arrow">▼</span>
                </summary>
                <div class="faq-answer">
                  <p>Most focus apps use rewards, streaks, or gentle reminders. We use consequences. Real, social, embarrassing consequences. It's the difference between a fitness tracker and a personal trainer who posts your weight online if you skip the gym.</p>
                </div>
              </details>
            </div>
          </div>
        </section>

        <section class="cta-section" id="download">
          <div class="container">
            <h2>Ready to Reclaim Your Focus?</h2>
            <p>On your deathbed, do you think you will regret not using your phone more?</p>
            <a href="https://apps.apple.com/app/blackmail-focus" target="_blank" rel="noopener">
              <img src="/images/appstorebadgewhite.svg" alt="Download on the App Store" class="app-badge">
            </a>
          </div>
        </section>

        <footer>
          <div class="container">
            <div class="footer-content">
              <div class="footer-section">
                <h4>Product</h4>
                <a href="/#download">Download</a>
                <a href="/manifesto">Manifesto</a>
                <a href="/press">Press Kit</a>
              </div>
              <div class="footer-section">
                <h4>Legal</h4>
                <a href="/privacy">Privacy Policy</a>
                <a href="/terms">Terms of Service</a>
              </div>
              <div class="footer-section">
                <h4>Contact</h4>
                <a href="/contact">Send us a message</a>
                <a href="https://twitter.com/blackmailwtf" target="_blank">@blackmailwtf</a>
              </div>
              <div class="footer-section">
                <h4>About</h4>
                <p>Blackmail.wtf helps you stay focused by using the power of shame. Built for people who are tired of being manipulated by their phones.</p>
              </div>
            </div>
            <div class="footer-bottom">
              <p class="quote">"On your deathbed, do you think you will regret not using your phone more?"</p>
              <p style="margin-top: 1rem;">© 2025 Blackmail.wtf</p>
            </div>
          </div>
        </footer>
      </body>
      </html>
    HTML
  end

  def manifesto_page_html
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Manifesto - Blackmail.wtf</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📵</text></svg>">
        <link rel="preload" href="/fonts/WhirlyBirdie-WideBold.otf" as="font" type="font/otf" crossorigin>
        #{shared_styles}
        <style>
          body { background: #fff; color: var(--bm-dark); }
          header {
            background: #000;
            padding: 15px 0;
            position: sticky;
            top: 0;
            z-index: 100;
          }
          .header-inner {
            display: flex;
            justify-content: space-between;
            align-items: center;
          }
          .header-title {
            color: var(--bm-blue);
            font-size: 1rem;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 2px;
          }
          .back-link {
            color: var(--bm-red);
            text-decoration: none;
            font-size: 1.5rem;
            font-weight: bold;
          }
          .hero-section {
            background: #fff;
            text-align: center;
            padding: 80px 20px;
          }
          .hero-section h1 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            font-size: 4rem;
            color: var(--bm-red);
            line-height: 1.1;
            margin-bottom: 1rem;
            letter-spacing: 2px;
          }
          .dark-section {
            background: var(--bm-dark);
            color: var(--bm-cream);
            padding: 60px 20px;
          }
          .dark-section h2 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            color: var(--bm-red);
            font-size: 2.2rem;
            text-align: center;
            margin-bottom: 2rem;
            letter-spacing: 1px;
          }
          .dark-section h3 {
            color: var(--bm-cream);
            font-size: 1.5rem;
            margin: 2rem 0 1rem;
          }
          .dark-section p {
            font-size: 1.15rem;
            line-height: 1.8;
            margin-bottom: 1.5rem;
            max-width: 700px;
            margin-left: auto;
            margin-right: auto;
          }
          .light-section {
            background: #fff;
            color: var(--bm-dark);
            padding: 60px 20px;
          }
          .light-section h2 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            color: var(--bm-dark);
            font-size: 2.5rem;
            text-align: center;
            margin-bottom: 2rem;
            letter-spacing: 1px;
          }
          .light-section p {
            font-size: 1.15rem;
            line-height: 1.8;
            margin-bottom: 1.5rem;
            max-width: 700px;
            margin-left: auto;
            margin-right: auto;
          }
          .image-circle {
            width: 250px;
            height: 250px;
            border-radius: 50%;
            border: 3px solid #fff;
            object-fit: cover;
            display: block;
            margin: 2rem auto;
          }
          .image-circle-blue {
            border-color: var(--bm-blue);
          }
          .quote-box {
            max-width: 100%;
            border-radius: 20px;
            margin: 2rem auto;
            display: block;
          }
          .shame-text {
            font-size: 3rem;
            color: var(--bm-red);
            font-weight: 900;
            text-align: center;
            margin: 2rem 0;
          }
          .divider {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin: 3rem auto;
            max-width: 500px;
          }
          .divider-line {
            flex: 1;
            height: 2px;
            background: var(--bm-blue);
          }
          .divider-text {
            color: var(--bm-blue);
            font-size: 1.2rem;
          }
          .buttons-section {
            background: #fff;
            padding: 0;
          }
          .manifesto-btn {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1.5rem 2rem;
            text-decoration: none;
            font-size: 1.2rem;
            font-weight: bold;
            width: 100%;
            transition: opacity 0.2s;
          }
          .manifesto-btn:hover { opacity: 0.9; }
          .manifesto-btn.black { background: #000; color: var(--bm-blue); }
          .manifesto-btn.pink { background: var(--bm-pink); color: var(--bm-red); }
          .manifesto-btn.cream { background: var(--bm-cream); color: var(--bm-red); }
          footer {
            background: #000;
            text-align: center;
            padding: 2rem;
            border-top: 2px solid var(--bm-blue);
          }
          footer p {
            color: var(--bm-blue);
            font-size: 0.9rem;
          }
          footer a {
            color: var(--bm-blue);
            text-decoration: none;
          }
          @media (max-width: 768px) {
            .hero-section h1 { font-size: 2.5rem; }
            .dark-section h2, .light-section h2 { font-size: 1.8rem; }
            .shame-text { font-size: 2rem; }
          }
        </style>
      </head>
      <body>
        <header>
          <div class="container">
            <div class="header-inner">
              <span class="header-title">↓ Manifesto</span>
              <a href="/" class="back-link">✕</a>
            </div>
          </div>
        </header>

        <section class="hero-section">
          <h1>No One is Bored,<br>Everything is Boring</h1>
        </section>

        <section class="dark-section">
          <div class="container">
            <h2>FREEDOM FROM YOUR PHONE</h2>

            <p>Right now some of the world's most talented people are working overtime to stop you from putting down your phone.</p>

            <p>But first look at this bird ↓</p>

            <img src="/images/pigeonOptiColor.gif" alt="Pigeon getting reward" class="image-circle">

            <p>Look at this pigeon. When the light comes on he gets a treat. He spends all his time pecking away, addicted to getting his little reward.</p>

            <p>He could be flying with his friends in the infinite blue sky, soaring through the clouds, crapping on people's heads.</p>

            <p>Instead he wastes his time chasing meaningless, positive feedback from an indifferent machine.</p>

            <p><strong>What an <em>IDIOT.</em></strong></p>

            <hr style="border: none; border-top: 2px wavy var(--bm-red); margin: 3rem 0;">

            <h3 style="text-align: center;">How did this happen?</h3>

            <p>This is B.F Skinner. He is the father of behavioral psychology.</p>

            <img src="/images/skinneropti.gif" alt="B.F. Skinner" class="image-circle">

            <p>Here he is experimenting on pigeons in his lab. ↓</p>

            <img src="/images/skinnerQuoteRedux.png" alt="Skinner Quote" class="quote-box">

            <p>Manipulating them to do his bidding through a simple system of semi-random rewards and punishments.</p>

            <p>These innovations were immediately implemented by the gambling industry.</p>

            <p>It turns out cutting-edge psychological research is very important when your profits depend on people consistently making bad decisions.</p>

            <img src="/images/casinoOpti.gif" alt="Casino" class="image-circle">

            <p>Ever been to a casino?</p>

            <p>Look around and you won't see joyful, smiling faces. You'll see an array of pained, stressed grimaces (and that's just the winners).</p>

            <p>Casinos have been designed with the help of psychologists to manipulate, coax and nudge people into gambling as long as possible.</p>

            <h3 style="text-align: center;">The Casino in your Pocket</h3>

            <p>In the early days of online gaming a software conglomerate employed a safeguarding team of behavioural psychologists to make sure their games weren't addictive.</p>

            <p>The psychologists produced a large report detailing all the things that the developers shouldn't do to hook their players. Of course, the sales department promptly sacked the psychologists and implemented every tactic, trick and strategy they had warned against.</p>

            <img src="/images/pigeonball.gif" alt="Pigeon playing" class="image-circle">

            <p>These same tactics are used to keep you on the hedonic treadmill that is your smartphone.</p>

            <h3 style="text-align: center; color: var(--bm-cream);">BIRD BRAIN</h3>

            <p>We are now the pigeons: Reduced to feedback in a cybernetic system optimised for slimy advertisers.</p>

            <img src="/images/pigtapppingopti.gif" alt="Pigeon tapping" class="image-circle">

            <p>The apps on your phone don't care about your wellbeing. Their purpose is to improve an abstract metric linked to a stranger's performance related bonus.</p>
          </div>
        </section>

        <section class="light-section">
          <div class="container">
            <h2 style="font-weight: 900;">BREAK FREE</h2>

            <img src="/images/pigeonFlyingHigh.png" alt="Flying pigeon" class="image-circle image-circle-blue">

            <p>On your deathbed do you think you will regret not using your phone more?</p>

            <img src="/images/shakespearmobile.png" alt="Shakespeare with phone" class="image-circle image-circle-blue">

            <p>Would Shakespeare have finished writing Hamlet if he'd had access to Raid Shadow Legends?</p>

            <p>Blackmail hopes to create a small space where you can be free from your phone.</p>

            <p>Fighting the modern psychological tactics of nudges and incentives is simple when you use the oldest motivational strategy, one not available to our pigeon friends:</p>

            <p class="shame-text">SHAME</p>

            <img src="/images/sadpigeonopti.gif" alt="Sad pigeon" class="image-circle">

            <div class="divider">
              <div class="divider-line"></div>
              <span class="divider-text">Postscript</span>
              <div class="divider-line"></div>
            </div>

            <h3 style="text-align: center; color: var(--bm-blue);">A Note about Boredom</h3>

            <p>The most valuable resource is time.</p>

            <p>Of course, you know this already, but you choose to ignore it.</p>

            <p>Frittering it away, tuned out, glued to your phone.</p>

            <p>Have you noticed that no one is bored but everything is boring?</p>

            <p>Maybe you remember a time when you weren't constantly occupied?</p>

            <p>The pre-smartphone era was one of intermittent boredom.</p>

            <p>Boredom is the mother of creativity.</p>

            <p>Now we experience constant low-level stimulation, often coupled with intermittent anxiety.</p>

            <p>Boredom was the dominant emotion of the industrial society.</p>

            <p>In the information society it has been replaced by anxiety.</p>

            <p>Putting down your phone, exiting the world of constant updates and micro-rewards, might help you to be more creative and less anxious.</p>

            <p>When you open an app, advertisers and data-miners bid for your attention in lightning-fast automated auctions. This skews rewards for app developers. Their primary goal is not to provide fun, utility, or value. It's to keep you hooked, to hijack your attention, and then rent it out to the highest bidder. Regaining your focus is very important.</p>

            <p>Not long ago, my phone broke. I found myself constantly fidgeting, looking for a non-existent device to check. I even felt phantom notifications, where I sensed a phone rattle in my empty pocket. At the same time, I spent a lot more time doing things that I felt were important. I didn't miss being constantly updated. After a few days, the FOMO faded away, and I felt much calmer.</p>
          </div>
        </section>

        <section class="buttons-section">
          <a href="/" class="manifesto-btn black">← GO BACK</a>
          <a href="/contact" class="manifesto-btn pink">✉ CONTACT</a>
          <a href="/#faq" class="manifesto-btn cream">? FAQ</a>
        </section>

        <footer>
          <p>© 2025 Blackmail.wtf</p>
          <p style="margin-top: 0.5rem;">
            <a href="/privacy">Privacy</a> • <a href="/terms">Terms</a>
          </p>
        </footer>
      </body>
      </html>
    HTML
  end

  def press_kit_html
    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Press Kit - Blackmail.wtf</title>
        <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>📵</text></svg>">
        <link rel="preload" href="/fonts/WhirlyBirdie-WideBold.otf" as="font" type="font/otf" crossorigin>
        #{shared_styles}
        <style>
          body { background: #000; color: var(--bm-cream); min-height: 100vh; }
          header {
            padding: 20px 0;
            border-bottom: 2px solid var(--bm-blue);
            margin-bottom: 40px;
          }
          .header-inner {
            display: flex;
            justify-content: space-between;
            align-items: center;
          }
          .back-link {
            color: var(--bm-blue);
            text-decoration: none;
            font-size: 1rem;
          }
          h1 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            font-size: 3.5rem;
            color: var(--bm-red);
            margin-bottom: 1rem;
            letter-spacing: 2px;
          }
          .subtitle {
            font-family: 'WhirlyBirdie', Georgia, serif;
            color: var(--bm-blue);
            font-size: 1.3rem;
            margin-bottom: 3rem;
            letter-spacing: 1px;
          }
          section {
            margin-bottom: 4rem;
          }
          h2 {
            font-family: 'WhirlyBirdie', Georgia, serif;
            color: var(--bm-blue);
            font-size: 1.6rem;
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid var(--bm-blue);
            letter-spacing: 1px;
          }
          .fact-sheet {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
          }
          .fact {
            background: rgba(79, 155, 196, 0.1);
            border: 1px solid var(--bm-blue);
            border-radius: 12px;
            padding: 1.5rem;
          }
          .fact-label {
            color: var(--bm-blue);
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 0.5rem;
          }
          .fact-value {
            color: var(--bm-cream);
            font-size: 1.1rem;
          }
          .description {
            font-size: 1.15rem;
            line-height: 1.8;
            max-width: 700px;
          }
          .description p { margin-bottom: 1rem; }
          .boilerplate {
            background: rgba(229, 51, 42, 0.1);
            border-left: 4px solid var(--bm-red);
            padding: 1.5rem;
            border-radius: 0 12px 12px 0;
            font-style: italic;
          }
          .assets-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
          }
          .asset-card {
            background: #111;
            border: 1px solid #333;
            border-radius: 12px;
            padding: 1.5rem;
            text-align: center;
          }
          .asset-preview {
            height: 80px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1rem;
          }
          .asset-preview img {
            max-height: 100%;
            max-width: 100%;
          }
          .asset-name {
            color: var(--bm-cream);
            font-weight: bold;
            margin-bottom: 0.5rem;
          }
          .asset-format {
            color: #888;
            font-size: 0.85rem;
            margin-bottom: 1rem;
          }
          .download-btn {
            display: inline-block;
            background: var(--bm-blue);
            color: #000;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: bold;
          }
          .contact-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
          }
          .contact-card {
            background: rgba(79, 155, 196, 0.1);
            border: 1px solid var(--bm-blue);
            border-radius: 12px;
            padding: 1.5rem;
          }
          .contact-card h3 {
            color: var(--bm-red);
            margin-bottom: 0.5rem;
          }
          .contact-card a {
            color: var(--bm-blue);
            text-decoration: none;
          }
          .contact-card p {
            color: #888;
            font-size: 0.9rem;
            margin-top: 0.5rem;
          }
          footer {
            text-align: center;
            padding: 3rem 0;
            border-top: 2px solid var(--bm-blue);
            margin-top: 4rem;
          }
          footer p { color: var(--bm-blue); }
          footer a { color: var(--bm-blue); text-decoration: none; }
        </style>
      </head>
      <body>
        <div class="container">
          <header>
            <div class="header-inner">
              <a href="/" class="back-link">← Back to Home</a>
              <img src="/images/BLACKMAILShadow.png" alt="BLACKMAIL" style="height: 30px;">
            </div>
          </header>

          <h1>Press Kit</h1>
          <p class="subtitle">Everything you need to write about Blackmail.wtf</p>

          <section>
            <h2>Fact Sheet</h2>
            <div class="fact-sheet">
              <div class="fact">
                <div class="fact-label">Product Name</div>
                <div class="fact-value">Blackmail</div>
              </div>
              <div class="fact">
                <div class="fact-label">Website</div>
                <div class="fact-value">blackmail.wtf</div>
              </div>
              <div class="fact">
                <div class="fact-label">Platform</div>
                <div class="fact-value">iOS</div>
              </div>
              <div class="fact">
                <div class="fact-label">Price</div>
                <div class="fact-value">Free</div>
              </div>
              <div class="fact">
                <div class="fact-label">Category</div>
                <div class="fact-value">Productivity / Focus</div>
              </div>
              <div class="fact">
                <div class="fact-label">Launch</div>
                <div class="fact-value">2025</div>
              </div>
            </div>
          </section>

          <section>
            <h2>Description</h2>
            <div class="description">
              <p><strong>Blackmail</strong> is a focus app that uses social accountability and the fear of embarrassment to help you stay off your phone.</p>
              <p>Users upload an embarrassing photo and share a unique "shame page" URL with friends. When they start a focus timer and pick up their phone before it ends, their embarrassing photo becomes visible on the shame page.</p>
              <p>The app fights fire with fire—using psychological pressure to counteract the addictive design patterns employed by social media and other apps.</p>
            </div>
          </section>

          <section>
            <h2>Boilerplate</h2>
            <div class="boilerplate">
              <p>Blackmail.wtf is a productivity app that helps users reclaim their focus by leveraging the power of social accountability. In a world where the brightest minds are employed to keep you scrolling, Blackmail offers a simple antidote: shame. Upload an embarrassing photo, share your page with friends, and watch your focus skyrocket when real consequences are on the line.</p>
            </div>
          </section>

          <section>
            <h2>Key Features</h2>
            <ul style="list-style: none; padding: 0;">
              <li style="padding: 0.8rem 0; border-bottom: 1px solid #333;">📸 <strong>Shame Photo Upload</strong> — Upload an embarrassing selfie as motivation</li>
              <li style="padding: 0.8rem 0; border-bottom: 1px solid #333;">🔗 <strong>Shareable Shame Pages</strong> — Unique anonymous URLs to share with friends</li>
              <li style="padding: 0.8rem 0; border-bottom: 1px solid #333;">⏰ <strong>Focus Timer</strong> — Customizable focus sessions from 5 minutes to 4 hours</li>
              <li style="padding: 0.8rem 0; border-bottom: 1px solid #333;">📱 <strong>Phone Face-Down Detection</strong> — Monitors when you pick up your phone</li>
              <li style="padding: 0.8rem 0; border-bottom: 1px solid #333;">🔒 <strong>Privacy Controls</strong> — Hide or delete your photo anytime</li>
              <li style="padding: 0.8rem 0;">🍎 <strong>Sign in with Apple</strong> — Quick, private authentication</li>
            </ul>
          </section>

          <section>
            <h2>Brand Assets</h2>
            <div class="assets-grid">
              <div class="asset-card">
                <div class="asset-preview">
                  <img src="/images/BLACKMAILShadow.png" alt="Logo">
                </div>
                <div class="asset-name">Logo (Dark)</div>
                <div class="asset-format">PNG, transparent</div>
                <a href="/images/BLACKMAILShadow.png" download class="download-btn">Download</a>
              </div>
              <div class="asset-card">
                <div class="asset-preview" style="background: #fff; border-radius: 8px;">
                  <img src="/images/BLACKMAILShadow.png" alt="Logo">
                </div>
                <div class="asset-name">Logo (Light)</div>
                <div class="asset-format">PNG, transparent</div>
                <a href="/images/BLACKMAILShadow.png" download class="download-btn">Download</a>
              </div>
              <div class="asset-card">
                <div class="asset-preview">
                  <div style="width: 60px; height: 60px; background: var(--bm-red); border-radius: 12px;"></div>
                </div>
                <div class="asset-name">App Icon</div>
                <div class="asset-format">PNG, 1024x1024</div>
                <a href="/images/app-icon.png" download class="download-btn">Download</a>
              </div>
            </div>
          </section>

          <section>
            <h2>Brand Colors</h2>
            <div class="assets-grid">
              <div class="asset-card">
                <div class="asset-preview">
                  <div style="width: 80px; height: 80px; background: #e5332a; border-radius: 8px;"></div>
                </div>
                <div class="asset-name">Blackmail Red</div>
                <div class="asset-format">#e5332a</div>
              </div>
              <div class="asset-card">
                <div class="asset-preview">
                  <div style="width: 80px; height: 80px; background: #4f9bc4; border-radius: 8px;"></div>
                </div>
                <div class="asset-name">Blackmail Blue</div>
                <div class="asset-format">#4f9bc4</div>
              </div>
              <div class="asset-card">
                <div class="asset-preview">
                  <div style="width: 80px; height: 80px; background: #120f0e; border-radius: 8px; border: 1px solid #333;"></div>
                </div>
                <div class="asset-name">Dark Background</div>
                <div class="asset-format">#120f0e</div>
              </div>
              <div class="asset-card">
                <div class="asset-preview">
                  <div style="width: 80px; height: 80px; background: #f9fafb; border-radius: 8px;"></div>
                </div>
                <div class="asset-name">Cream</div>
                <div class="asset-format">#f9fafb</div>
              </div>
            </div>
          </section>

          <section>
            <h2>Contact</h2>
            <div class="contact-grid">
              <div class="contact-card">
                <h3>Press & General Inquiries</h3>
                <a href="/contact">Send us a message</a>
                <p>For interviews, reviews, partnerships, and media requests</p>
              </div>
              <div class="contact-card">
                <h3>Social</h3>
                <a href="https://twitter.com/blackmailwtf" target="_blank">@blackmailwtf</a>
                <p>Follow for updates and announcements</p>
              </div>
            </div>
          </section>

          <footer>
            <p>© 2025 Blackmail.wtf</p>
            <p style="margin-top: 0.5rem;">
              <a href="/">Home</a> • <a href="/manifesto">Manifesto</a> • <a href="/privacy">Privacy</a> • <a href="/terms">Terms</a>
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
              <li>Delete your account entirely from the app settings</li>
            </ul>
          </section>

          <section>
            <h2>6. Contact Us</h2>
            <p>For privacy-related questions, <a href="/contact">contact us here</a>.</p>
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
            <p>Questions about these terms? <a href="/contact">Contact us here</a>.</p>
          </section>
        </div>
      </body>
      </html>
    HTML
  end

  def legal_page_styles
    <<~CSS
      #{shared_styles}
      <style>
        body {
          background: #000;
          color: var(--bm-cream);
          min-height: 100vh;
          padding: 20px;
        }
        .container { max-width: 800px; margin: 0 auto; }
        .back-link {
          display: inline-block;
          color: var(--bm-blue);
          text-decoration: none;
          margin-bottom: 2rem;
          font-size: 1rem;
        }
        .back-link:hover { text-decoration: underline; }
        h1 {
          font-size: 2.5rem;
          color: var(--bm-red);
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
          border-left: 3px solid var(--bm-blue);
        }
        h2 {
          color: var(--bm-blue);
          font-size: 1.3rem;
          margin-bottom: 1rem;
        }
        p { margin-bottom: 1rem; }
        ul {
          margin-left: 1.5rem;
          margin-bottom: 1rem;
        }
        li { margin-bottom: 0.5rem; }
        a { color: var(--bm-blue); }
        a:hover { color: #6fb5d8; }
        @media (max-width: 768px) {
          h1 { font-size: 2rem; }
        }
      </style>
    CSS
  end
end
