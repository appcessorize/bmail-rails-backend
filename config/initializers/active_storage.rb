# Disable checksum headers for Cloudflare R2 compatibility
# R2 rejects requests with multiple checksum headers that aws-sdk-s3 sends by default
Rails.application.config.after_initialize do
  if defined?(Aws::S3)
    Aws.config.update(
      request_checksum_calculation: "when_required",
      response_checksum_validation: "when_required"
    )
  end
end
