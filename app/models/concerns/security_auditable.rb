module SecurityAuditable
  extend ActiveSupport::Concern

  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: "security_audit",
      type: event_type,
      user_id: self.id,
      username: self.username,
      timestamp: Time.current.iso8601,
      details: details
    }.to_json)
  end
end
