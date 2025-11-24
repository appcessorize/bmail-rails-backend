class ApplicationController < ActionController::API
  before_action :set_default_format

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    @current_user = User.find_by_valid_token(token)

    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def set_default_format
    request.format = :json
  end
end
