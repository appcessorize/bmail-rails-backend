class SessionsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy]

  # POST /login
  def create
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      # Generate new token and hash it
      user.generate_auth_token
      user.save!

      user.log_security_event('login_success', { ip: request.remote_ip })

      render json: {
        user: {
          id: user.id,
          username: user.username
        },
        auth_token: user.auth_token
      }, status: :ok
    else
      Rails.logger.warn({
        event: 'security_audit',
        type: 'login_failed',
        username: params[:username],
        ip: request.remote_ip,
        timestamp: Time.current.iso8601
      }.to_json)

      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end

  # DELETE /logout
  def destroy
    # Invalidate token by expiring it immediately
    current_user.update(token_expires_at: Time.current)
    head :no_content
  end
end
