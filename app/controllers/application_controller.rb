class ApplicationController < ActionController::API
  before_action :set_default_format

  private

  def authenticate_user!
    auth_header = request.headers["Authorization"].to_s
    token = auth_header.start_with?("Bearer ") ? auth_header[7..] : nil
    @current_user = User.find_by_valid_token(token)

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def verify_app_attest!
    return unless ENV["REQUIRE_APP_ATTEST"] == "true"

    key_id = request.headers["X-App-Key-Id"]
    assertion_b64 = request.headers["X-App-Assertion"]

    unless key_id.present? && assertion_b64.present?
      Rails.logger.info("[AppAttest] Missing headers - key_id: #{key_id.present?}, assertion: #{assertion_b64.present?}")
      return render json: { error: "attestation_required", error_code: "attestation_required" }, status: :forbidden
    end

    credential = AppAttestCredential.find_by(user: @current_user, key_id: key_id)
    unless credential
      Rails.logger.info("[AppAttest] Unknown key_id: #{key_id} for user #{@current_user&.id}")
      return render json: { error: "unknown_attestation_key" }, status: :forbidden
    end

    client_data = build_client_data_hash(request)
    assertion_data = Base64.decode64(assertion_b64)
    AppAttestVerificationService.new.verify_assertion(assertion_data, credential, client_data)
  rescue AppAttestVerificationService::VerificationError => e
    Rails.logger.warn({
      event: "security_audit",
      type: "attestation_failed",
      user_id: @current_user&.id,
      error: e.message,
      ip: request.remote_ip,
      timestamp: Time.current.iso8601
    }.to_json)

    render json: { error: "attestation_failed" }, status: :forbidden
  end

  def build_client_data_hash(request)
    body_hash = Digest::SHA256.hexdigest(request.raw_post.to_s)
    canonical = "#{request.method} #{request.path} #{body_hash}"
    Digest::SHA256.digest(canonical)
  end

  def set_default_format
    request.format = :json
  end
end
