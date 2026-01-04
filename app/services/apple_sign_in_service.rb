require "net/http"
require "uri"
require "json"

class AppleSignInService
  APPLE_PUBLIC_KEY_URL = "https://appleid.apple.com/auth/keys"
  EXPECTED_ISSUER = "https://appleid.apple.com"
  EXPECTED_AUDIENCE = "com.expomang.Blackmail-Focus-or-else"

  class AppleSignInError < StandardError; end

  def initialize(identity_token)
    @identity_token = identity_token
  end

  def verify_and_decode
    # Decode the JWT without verification first to get the kid (key ID)
    unverified_token = JWT.decode(@identity_token, nil, false)
    header = unverified_token[1]
    kid = header["kid"]

    # Fetch Apple's public keys
    public_keys = fetch_apple_public_keys
    matching_key = find_matching_key(public_keys, kid)

    raise AppleSignInError, "No matching public key found" unless matching_key

    # Convert JWK to OpenSSL key
    jwk = JWT::JWK.import(matching_key)

    # Verify and decode the JWT
    decoded_token = JWT.decode(
      @identity_token,
      jwk.public_key,
      true,
      {
        algorithm: "RS256",
        iss: EXPECTED_ISSUER,
        aud: EXPECTED_AUDIENCE,
        verify_iss: true,
        verify_aud: true,
        verify_iat: true
      }
    )

    decoded_token[0] # Return the payload
  rescue JWT::DecodeError => e
    Rails.logger.error "Apple JWT decode error: #{e.message}"
    raise AppleSignInError, "Invalid token: #{e.message}"
  rescue StandardError => e
    Rails.logger.error "Apple sign in error: #{e.message}"
    raise AppleSignInError, "Verification failed: #{e.message}"
  end

  private

  def fetch_apple_public_keys
    uri = URI(APPLE_PUBLIC_KEY_URL)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5  # 5 seconds to establish connection
    http.read_timeout = 10 # 10 seconds to read response

    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise AppleSignInError, "Failed to fetch Apple public keys"
    end

    JSON.parse(response.body)["keys"]
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error "Apple public keys fetch timeout: #{e.message}"
    raise AppleSignInError, "Timeout fetching Apple public keys"
  rescue StandardError => e
    Rails.logger.error "Failed to fetch Apple public keys: #{e.message}"
    raise AppleSignInError, "Could not retrieve Apple public keys"
  end

  def find_matching_key(keys, kid)
    keys.find { |key| key["kid"] == kid }
  end
end
