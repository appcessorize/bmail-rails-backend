# Security headers middleware
# Adds standard security headers to all responses

Rails.application.config.action_dispatch.default_headers = {
  # Prevent clickjacking - only allow framing from same origin
  "X-Frame-Options" => "SAMEORIGIN",

  # Prevent MIME type sniffing
  "X-Content-Type-Options" => "nosniff",

  # Enable XSS filter in browsers (legacy, but doesn't hurt)
  "X-XSS-Protection" => "1; mode=block",

  # Referrer policy - don't leak full URL to external sites
  "Referrer-Policy" => "strict-origin-when-cross-origin",

  # Permissions policy - disable sensitive browser features we don't use
  "Permissions-Policy" => "camera=(), microphone=(), geolocation=()"
}

# Note: HSTS is handled by config.force_ssl in production.rb
# Note: CSP not added - API-only app, would need careful tuning for web views
