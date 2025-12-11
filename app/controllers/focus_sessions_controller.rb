class FocusSessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_focus_session, only: [:show, :complete, :fail]

  # GET /focus_sessions
  # List user's focus sessions
  def index
    sessions = current_user.focus_sessions.recent.limit(50)
    render json: sessions.map { |s| session_json(s) }
  end

  # GET /focus_sessions/:id
  def show
    render json: session_json(@focus_session)
  end

  # POST /focus_sessions
  # Start a new focus session
  def create
    # Cancel any existing active sessions
    current_user.focus_sessions.active.update_all(status: 'cancelled', ended_at: Time.current)

    session = current_user.focus_sessions.new(
      duration_minutes: params[:duration_minutes],
      started_at: Time.current,
      status: 'active'
    )

    if session.save
      render json: session_json(session), status: :created
    else
      render json: { errors: session.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /focus_sessions/:id/complete
  # Mark session as successfully completed
  def complete
    unless @focus_session.active?
      return render json: { error: "Session is not active" }, status: :unprocessable_entity
    end

    @focus_session.complete!
    render json: session_json(@focus_session)
  end

  # PATCH /focus_sessions/:id/fail
  # Mark session as failed - activates shame!
  def fail
    unless @focus_session.active?
      return render json: { error: "Session is not active" }, status: :unprocessable_entity
    end

    @focus_session.fail!
    render json: session_json(@focus_session).merge(
      shame_activated: true,
      shame_page_url: page_url_for(current_user)
    )
  end

  # GET /focus_sessions/current
  # Get the current active session if any
  def current
    session = current_user.focus_sessions.active.first

    if session
      render json: session_json(session)
    else
      render json: { active_session: nil }
    end
  end

  private

  def set_focus_session
    @focus_session = current_user.focus_sessions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Focus session not found" }, status: :not_found
  end

  def session_json(session)
    {
      id: session.id,
      duration_minutes: session.duration_minutes,
      started_at: session.started_at.iso8601,
      ended_at: session.ended_at&.iso8601,
      status: session.status,
      created_at: session.created_at.iso8601
    }
  end

  def page_url_for(user)
    return nil unless user.page_slug.present?
    "#{request.base_url}/p/#{user.page_slug}"
  end
end
