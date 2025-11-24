# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In development, allow localhost
    if Rails.env.development?
      origins 'localhost:3000', '127.0.0.1:3000', /\Ahttp:\/\/localhost:\d+\z/
    else
      # In production, set your actual domain(s)
      # Replace with your actual production domain
      origins ENV.fetch('ALLOWED_ORIGINS', 'your-production-domain.com').split(',')
    end

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      max_age: 86400
  end
end
