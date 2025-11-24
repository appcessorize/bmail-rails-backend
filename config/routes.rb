Rails.application.routes.draw do
  # Landing page at root
  root "pages#home"

  # API endpoints
  post   "/signup", to: "users#create"
  get    "/me",     to: "users#me"

  post   "/login",  to: "sessions#create"
  post   "/auth/apple", to: "sessions#apple"
  delete "/logout", to: "sessions#destroy"

  post   "/upload_image", to: "users#upload_image"
  patch  "/update_image_privacy", to: "users#update_image_privacy"
  delete "/delete_image", to: "users#delete_image"

  resources :entries
end
