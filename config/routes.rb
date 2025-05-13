Rails.application.routes.draw do
  # devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      # Devise routes for JWT authentication
      devise_for :users, path: "", path_names: {
        sign_in: "login",      # /api/v1/login
        sign_out: "logout",    # /api/v1/logout
        registration: "signup" # /api/v1/signup
      }, controllers: {
        sessions: "api/v1/sessions",
        registrations: "api/v1/registrations"
      }, defaults: { format: :json } # Ensure default format is JSON

      # Example of a protected route:
      # get '/profile', to: 'profiles#show' # Assuming you create a ProfilesController
    end
  end
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
