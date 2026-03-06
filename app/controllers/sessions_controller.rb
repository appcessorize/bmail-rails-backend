class SessionsController < ApplicationController
  before_action :authenticate_user!, only: [ :destroy ]
  before_action :verify_app_attest!, only: [ :destroy ]

  # POST /login
  def create
    user = User.find_by(username: params[:username])

    if user.nil?
      # User not found - return generic error to prevent username enumeration
      Rails.logger.info({
        event: "security_audit",
        type: "login_user_not_found",
        username: params[:username],
        ip: request.remote_ip,
        timestamp: Time.current.iso8601
      }.to_json)

      render json: { error: "invalid_credentials", error_code: "invalid_credentials" }, status: :unauthorized
    elsif user.locked?
      # Account is locked due to too many failed attempts
      Rails.logger.warn({
        event: "security_audit",
        type: "login_account_locked",
        username: params[:username],
        ip: request.remote_ip,
        locked_until: user.locked_until.iso8601,
        timestamp: Time.current.iso8601
      }.to_json)

      render json: {
        error: "account_locked",
        error_code: "account_locked",
        locked_until: user.locked_until.iso8601,
        retry_after: user.lockout_remaining
      }, status: :too_many_requests
    elsif user.authenticate(params[:password])
      # Successful login - reset failed attempts and generate token
      user.reset_failed_logins!
      user.generate_auth_token
      user.save!(validate: false)

      user.log_security_event("login_success", { ip: request.remote_ip })

      render json: {
        user: {
          id: user.id,
          username: user.username
        },
        auth_token: user.auth_token,
        token_expires_at: user.token_expires_at&.iso8601,
        refresh_token: user.refresh_token,
        refresh_token_expires_at: user.refresh_token_expires_at&.iso8601
      }, status: :ok
    else
      # Wrong password - record failed attempt
      user.record_failed_login!

      Rails.logger.warn({
        event: "security_audit",
        type: "login_wrong_password",
        username: params[:username],
        ip: request.remote_ip,
        failed_attempts: user.failed_login_attempts,
        timestamp: Time.current.iso8601
      }.to_json)

      # Return appropriate error based on lockout status
      if user.locked?
        render json: {
          error: "account_locked",
          error_code: "account_locked",
          locked_until: user.locked_until.iso8601,
          retry_after: user.lockout_remaining
        }, status: :too_many_requests
      else
        render json: {
          error: "invalid_credentials",
          error_code: "invalid_credentials"
        }, status: :unauthorized
      end
    end
  end

  # POST /auth/apple
  def apple
    identity_token = params[:identity_token]
    apple_user_id = params[:apple_user_id]
    email = params[:email]
    first_name = params[:first_name]
    last_name = params[:last_name]

    # Verify the Apple JWT token
    service = AppleSignInService.new(identity_token)
    decoded_token = service.verify_and_decode

    # The 'sub' claim contains the Apple user ID
    verified_apple_user_id = decoded_token["sub"]

    # Security: ensure the apple_user_id from the client matches the verified one
    unless verified_apple_user_id == apple_user_id
      return render json: { error: "Apple user ID mismatch" }, status: :unauthorized
    end

    # Find or create user by apple_user_id
    user = User.find_by(apple_user_id: verified_apple_user_id)

    if user
      # Existing user - log them in
      user.generate_auth_token
      user.save!(validate: false)
      user.log_security_event("apple_login_success", { ip: request.remote_ip })
    else
      # New user - create account
      # Generate a unique username from email or apple_user_id
      base_username = if email.present?
        email.split("@").first
      elsif first_name.present?
        first_name.downcase
      else
        "user_#{SecureRandom.hex(4)}"
      end

      username = base_username
      counter = 1
      while User.exists?(username: username)
        username = "#{base_username}#{counter}"
        counter += 1
      end

      # Create user without password (Apple sign in only)
      user = User.new(
        username: username,
        email: email,
        apple_user_id: verified_apple_user_id
      )

      user.save!
      user.log_security_event("apple_signup_success", { ip: request.remote_ip })
    end

    render json: {
      user: {
        id: user.id,
        username: user.username
      },
      auth_token: user.auth_token,
      token_expires_at: user.token_expires_at&.iso8601,
      refresh_token: user.refresh_token,
      refresh_token_expires_at: user.refresh_token_expires_at&.iso8601
    }, status: :ok
  rescue AppleSignInService::AppleSignInError => e
    Rails.logger.warn({
      event: "security_audit",
      type: "apple_login_failed",
      error: e.message,
      ip: request.remote_ip,
      timestamp: Time.current.iso8601
    }.to_json)

    render json: { error: "Apple sign in failed" }, status: :unauthorized
  rescue StandardError => e
    Rails.logger.error "Apple sign in error: #{e.message}\n#{e.backtrace.join("\n")}"
    render json: { error: "An error occurred during Apple sign in" }, status: :internal_server_error
  end

  # POST /auth/refresh
  def refresh
    refresh_token = params[:refresh_token]
    user = User.find_by_valid_refresh_token(refresh_token)

    if user
      user.generate_auth_token
      user.save!(validate: false)
      user.log_security_event("token_refreshed", { ip: request.remote_ip })

      render json: {
        auth_token: user.auth_token,
        token_expires_at: user.token_expires_at&.iso8601,
        refresh_token: user.refresh_token,
        refresh_token_expires_at: user.refresh_token_expires_at&.iso8601
      }, status: :ok
    else
      render json: { error: "invalid_refresh_token" }, status: :unauthorized
    end
  end

  # DELETE /logout
  def destroy
    # Fully invalidate token by clearing digest and expiring
    current_user.update(
      token_digest: nil,
      token_expires_at: Time.current,
      refresh_token_digest: nil,
      refresh_token_expires_at: Time.current
    )
    current_user.log_security_event("logout", { ip: request.remote_ip })
    head :no_content
  end
end
