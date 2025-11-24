class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: [:show, :update, :destroy]

  # GET /entries
  def index
    entries = current_user.entries.order(created_at: :desc)
    render json: entries
  end

  # GET /entries/:id
  def show
    render json: @entry
  end

  # POST /entries
  def create
    entry = current_user.entries.new(entry_params)

    if entry.save
      render json: entry, status: :created
    else
      render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /entries/:id
  def update
    if @entry.update(entry_params)
      render json: @entry
    else
      render json: { errors: @entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /entries/:id
  def destroy
    @entry.destroy
    head :no_content
  end

  private

  def set_entry
    @entry = current_user.entries.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Not found' }, status: :not_found
  end

  def entry_params
    params.require(:entry).permit(:title, :body)
  end
end
