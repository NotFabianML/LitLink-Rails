# Rails.application.routes.draw do
#   devise_for :users
#   namespace :api do
#     namespace :v1 do
#       # Autenticación
#       post "/signup", to: "auth#signup"
#       post "/login", to: "auth#login"

#       # Preferencias
#       resource :preferences, only: [ :show, :update ]

#       # Libros
#       get "/books/recommendations", to: "books#recommendations"
#       get "/books/search", to: "books#search"

#       # Interacciones
#       resources :book_interactions, only: [ :index, :create ]
#     end
#   end
# end


Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Autenticación
      post "/signup", to: "auth#signup"
      post "/login", to: "auth#login"

      # Recursos
      resources :users, only: [ :index, :show, :create, :update, :destroy ]
      resources :books, only: [ :index, :show, :create, :update, :destroy ]

      # Rutas adicionales
      resource :preferences, only: [ :show, :update ]
      resources :book_interactions, only: [ :index, :create ]
      get "/recommendations", to: "books#recommendations"
    end
  end

  # Health Check
  get "/health", to: proc { [ 200, {}, [ "OK" ] ] }
end
