Rails.application.routes.draw do
  # Landing page at root
  root "pages#home"

  # Legal pages
  get "/privacy", to: "pages#privacy"
  get "/terms", to: "pages#terms"

  # Content pages
  get "/manifesto", to: "pages#manifesto"
  get "/press", to: "pages#press"
  get "/support", to: "pages#support"
  get "/contact", to: "contacts#new"
  post "/contact", to: "contacts#create"

  # Admin endpoints
  get "/admin/login", to: "admin#login"
  post "/admin/authenticate", to: "admin#authenticate"
  get "/admin", to: "admin#dashboard"
  post "/admin/users/:id/deactivate_shame", to: "admin#deactivate_shame"
  delete "/admin/users/:id", to: "admin#delete_user"
  post "/admin/reports/:id/resolve", to: "admin#resolve_report"
  post "/admin/contacts/:id/read", to: "admin#mark_contact_read"
  get "/admin/contacts", to: "contacts#index"
  get "/admin/reports", to: "shame_pages#reports_index"

  # Public shame page (no auth required)
  get "/p/:slug", to: "shame_pages#show", as: :shame_page
  get "/p/:slug/image", to: "shame_pages#image", as: :shame_page_image
  post "/p/:slug/report", to: "shame_pages#report", as: :shame_page_report
  post "/p/:slug/watch", to: "shame_pages#watch", as: :shame_page_watch
  get "/unsubscribe/:token", to: "shame_pages#unsubscribe", as: :unsubscribe_watcher

  # API endpoints
  get    "/me",     to: "users#me"

  post   "/auth/apple", to: "sessions#apple"
  post   "/auth/refresh", to: "sessions#refresh"
  delete "/logout", to: "sessions#destroy"

  get  "/attest/challenge", to: "attestations#challenge"
  post "/attest",           to: "attestations#create"
  delete "/delete_account", to: "users#destroy"
  delete "/my_page", to: "users#delete_page"

  post   "/upload_image", to: "users#upload_image"
  patch  "/update_image_privacy", to: "users#update_image_privacy"
  delete "/delete_image", to: "users#delete_image"

  get    "/users/:user_id/image", to: "images#show"

  # Focus sessions API
  resources :focus_sessions, only: [:index, :show, :create] do
    member do
      patch :complete
      patch :fail
    end
    collection do
      get :current
    end
  end

  # Shame control
  patch "/shame/deactivate", to: "users#deactivate_shame"

  resources :entries
end
