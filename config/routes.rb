Rails.application.routes.draw do
  # Landing page at root
  root "pages#home"

  # Legal pages
  get "/privacy", to: "pages#privacy"
  get "/terms", to: "pages#terms"

  # Content pages
  get "/manifesto", to: "pages#manifesto"
  get "/press", to: "pages#press"
  get "/contact", to: "contacts#new"
  post "/contact", to: "contacts#create"

  # Admin endpoints
  get "/admin/contacts", to: "contacts#index"

  # Public shame page (no auth required)
  get "/p/:slug", to: "shame_pages#show", as: :shame_page

  # API endpoints
  post   "/signup", to: "users#create"
  get    "/me",     to: "users#me"

  post   "/login",  to: "sessions#create"
  post   "/auth/apple", to: "sessions#apple"
  delete "/logout", to: "sessions#destroy"
  delete "/delete_account", to: "users#destroy"

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
