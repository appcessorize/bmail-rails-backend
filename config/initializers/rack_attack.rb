class Rack::Attack
  # Throttle login attempts by username
  throttle("login/username", limit: 5, period: 60) do |req|
    if req.path == "/login" && req.post?
      req.params["username"].presence
    end
  end

  # Throttle signup attempts by IP
  throttle("signup/ip", limit: 3, period: 300) do |req|
    if req.path == "/signup" && req.post?
      req.ip
    end
  end

  # Throttle file uploads by IP
  throttle("upload_image/ip", limit: 10, period: 60) do |req|
    if req.path == "/upload_image" && req.post?
      req.ip
    end
  end

  # Throttle contact form submissions by IP
  throttle("contact/ip", limit: 5, period: 300) do |req|
    if req.path == "/contact" && req.post?
      req.ip
    end
  end

  # Throttle content reports by IP
  throttle("report/ip", limit: 5, period: 300) do |req|
    if req.path.match?(%r{\A/p/.+/report\z}) && req.post?
      req.ip
    end
  end

  # Throttle page watch subscriptions by IP
  throttle("watch/ip", limit: 10, period: 300) do |req|
    if req.path.match?(%r{\A/p/.+/watch\z}) && req.post?
      req.ip
    end
  end

  # Throttle admin endpoint by IP (prevents brute-force on admin token)
  throttle("admin/ip", limit: 5, period: 60) do |req|
    if req.path.start_with?("/admin")
      req.ip
    end
  end

  # Throttle Apple auth by IP
  throttle("apple_auth/ip", limit: 5, period: 60) do |req|
    if req.path == "/auth/apple" && req.post?
      req.ip
    end
  end

  # Throttle attestation challenge requests
  throttle("attest_challenge/ip", limit: 10, period: 60) do |req|
    req.ip if req.path == "/attest/challenge" && req.get?
  end

  # Throttle attestation creation requests
  throttle("attest/ip", limit: 5, period: 60) do |req|
    req.ip if req.path == "/attest" && req.post?
  end

  # Throttle token refresh requests
  throttle("auth_refresh/ip", limit: 20, period: 60) do |req|
    req.ip if req.path == "/auth/refresh" && req.post?
  end

  # General request throttling by IP
  throttle("req/ip", limit: 300, period: 60) do |req|
    req.ip
  end

  # Block requests that are too large (potential DoS)
  blocklist("block_large_requests") do |req|
    # Block requests larger than 10MB
    req.content_length && req.content_length.to_i > 10.megabytes
  end
end
