class AttestationsController < ApplicationController
  before_action :authenticate_user!

  # GET /attest/challenge
  def challenge
    nonce = SecureRandom.hex(16)
    Rails.cache.write("attest_challenge:#{current_user.id}", nonce, expires_in: 5.minutes)
    render json: { challenge: nonce }
  end

  # POST /attest
  def create
    challenge = Rails.cache.read("attest_challenge:#{current_user.id}")
    Rails.cache.delete("attest_challenge:#{current_user.id}")

    unless challenge.present?
      return render json: { error: "challenge_expired" }, status: :unprocessable_entity
    end

    key_id = params[:key_id]
    attestation_object = params[:attestation_object]

    unless key_id.present? && attestation_object.present?
      return render json: { error: "missing_parameters" }, status: :unprocessable_entity
    end

    service = AppAttestVerificationService.new
    credential = service.verify_attestation(attestation_object, key_id, challenge, current_user)

    render json: { status: "attested", key_id: credential.key_id }, status: :created
  rescue AppAttestVerificationService::VerificationError => e
    Rails.logger.warn({
      event: "security_audit",
      type: "attestation_failed",
      user_id: current_user.id,
      error: e.message,
      ip: request.remote_ip,
      timestamp: Time.current.iso8601
    }.to_json)

    render json: { error: "attestation_failed", detail: e.message }, status: :unprocessable_entity
  end
end
