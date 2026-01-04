class UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :me, :upload_image, :update_image_privacy, :delete_image, :deactivate_shame, :destroy ]

  # POST /signup
  def create
    user = User.new(user_params)

    if user.save
      render json: {
        user: {
          id: user.id,
          username: user.username
        },
        auth_token: user.auth_token,
        token_expires_at: user.token_expires_at&.iso8601
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /me
  def me
    user = current_user
    response = {
      id: user.id,
      username: user.username,
      email: user.email,
      image_public: user.image_public,
      page_slug: user.page_slug,
      page_url: user.page_slug.present? ? "#{request.base_url}/p/#{user.page_slug}" : nil,
      shame_active: user.shame_active,
      shame_activated_at: user.shame_activated_at&.iso8601
    }

    if user.profile_image.attached?
      response[:has_image] = true
      response[:image_url] = url_for(controller: "images", action: "show", user_id: user.id, only_path: false)
    else
      response[:has_image] = false
    end

    render json: response
  end

  # POST /upload_image
  def upload_image
    if params[:image].present?
      current_user.profile_image.purge if current_user.profile_image.attached?
      current_user.profile_image.attach(params[:image])

      if current_user.valid?
        current_user.log_security_event("image_uploaded", {
          content_type: params[:image].content_type,
          size: params[:image].size,
          ip: request.remote_ip
        })

        image_url = url_for(controller: "images", action: "show", user_id: current_user.id, only_path: false)
        render json: { message: "Image uploaded successfully", image_url: image_url }, status: :ok
      else
        current_user.profile_image.purge
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "No image provided" }, status: :unprocessable_entity
    end
  end

  # PATCH /update_image_privacy
  def update_image_privacy
    if current_user.update(image_public: params[:image_public])
      current_user.log_security_event("image_privacy_changed", {
        new_value: params[:image_public],
        ip: request.remote_ip
      })

      render json: { message: "Privacy updated", image_public: current_user.image_public }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /delete_image
  def delete_image
    if current_user.profile_image.attached?
      current_user.profile_image.purge
      render json: { message: "Image deleted successfully" }, status: :ok
    else
      render json: { error: "No image to delete" }, status: :not_found
    end
  end

  # PATCH /shame/deactivate
  def deactivate_shame
    current_user.deactivate_shame!
    render json: {
      message: "Shame deactivated",
      shame_active: current_user.shame_active
    }, status: :ok
  end

  # DELETE /delete_account
  def destroy
    current_user.log_security_event("account_deleted", { ip: request.remote_ip })
    current_user.destroy
    render json: { message: "Account deleted successfully" }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
