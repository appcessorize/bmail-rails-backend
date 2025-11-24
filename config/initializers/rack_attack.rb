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
