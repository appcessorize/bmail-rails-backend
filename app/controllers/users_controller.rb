class UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :me, :upload_image, :update_image_privacy, :delete_image, :deactivate_shame, :destroy, :delete_page, :ensure_page ]
  before_action :verify_app_attest!, only: [ :me, :upload_image, :update_image_privacy, :delete_image, :deactivate_shame, :destroy, :delete_page, :ensure_page ]

  # GET /me
  def me
    user = current_user
    response = {
      id: user.id,
      username: user.username,
      email: user.email,
      image_public: user.image_public,
      page_slug: user.page_slug,
      page_url: user.page_slug.present? ? "#{ENV.fetch("PUBLIC_BASE_URL", request.base_url)}/p/#{user.page_slug}" : nil,
      shame_active: user.shame_active,
      shame_activated_at: user.shame_activated_at&.iso8601,
      page_deleted: user.page_deleted
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
      # Validate magic bytes from upload tempfile BEFORE sending to R2
      header = params[:image].tempfile.tap(&:rewind).read(6)
      params[:image].tempfile.rewind

      valid_magic = User::MAGIC_BYTES.any? do |magic, types|
        header.byteslice(0, magic.bytesize) == magic &&
          types.include?(params[:image].content_type)
      end

      unless valid_magic
        return render json: { errors: ["Image file type is invalid"] }, status: :unprocessable_entity
      end

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

  # DELETE /my_page
  def delete_page
    current_user.profile_image.purge if current_user.profile_image.attached?
    current_user.update!(
      shame_active: false,
      shame_activated_at: nil,
      page_slug: nil,
      image_public: false,
      page_deleted: true
    )
    render json: { message: "Page deleted" }
  end

  # POST /ensure_page
  def ensure_page
    user = current_user

    unless user.page_slug.present?
      # Clear page_deleted first so generate_page_slug doesn't early-return
      user.page_deleted = false
      user.generate_page_slug
      user.save!
    end

    render json: {
      page_slug: user.page_slug,
      page_url: "#{ENV.fetch("PUBLIC_BASE_URL", request.base_url)}/p/#{user.page_slug}"
    }
  end

  # DELETE /delete_account
  def destroy
    current_user.log_security_event("account_deleted", { ip: request.remote_ip })
    current_user.destroy
    render json: { message: "Account deleted successfully" }, status: :ok
  end

  private
end
