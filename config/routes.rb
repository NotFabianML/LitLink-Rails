# Rails.application.routes.draw do
#   namespace :api do
#     namespace :v1 do
#       post "/auth/login", to: "auth#login"
#       post "/auth/signup", to: "auth#signup"

#       resources :users, except: [ :new, :edit ] do
#         resource :preference, only: [ :show, :create, :update, :destroy ]
#         resources :user_book_interactions, path: "interactions", only: [ :index, :show, :create, :update, :destroy ]
#       end

#       resources :books, except: [ :new, :edit ] do
#         collection do
#           get :search
#         end
#       end
#     end
#   end
# end


Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Autenticación
      post "/auth/login", to: "auth#login"
      post "/auth/signup", to: "auth#signup"
      get "/auth/me", to: "auth#me"  # Obtener información del usuario autenticado

      # Usuarios
      resources :users, except: [ :new, :edit ]

      # Preferencias (ya no anidadas bajo users)
      resource :preference, only: [ :show, :create, :update, :destroy ]  # Singular (1 por usuario)

      # Acciones de libros (book_actions)
      resources :book_actions, except: [ :new, :edit ]

      # Búsqueda de libros (OpenLibrary)
      get "/books/search", to: "books#search"
      get "/books/saved", to: "books#saved"
      get "/books/recommend", to: "books#recommend"
    end
  end
end


# # Autenticación
# POST   /api/v1/auth/signup
# POST   /api/v1/auth/login
# GET    /api/v1/auth/me

# # Usuarios
# GET    /api/v1/users
# POST   /api/v1/users
# GET    /api/v1/users/:id
# PATCH  /api/v1/users/:id
# DELETE /api/v1/users/:id

# # Preferencias
# GET    /api/v1/preference
# POST   /api/v1/preference
# PATCH  /api/v1/preference
# DELETE /api/v1/preference

# # BookActions
# GET    /api/v1/book_actions
# POST   /api/v1/book_actions
# GET    /api/v1/book_actions/:id
# PATCH  /api/v1/book_actions/:id
# DELETE /api/v1/book_actions/:id

# # Búsqueda de libros
# GET     /api/v1/books/saved
# GET    /api/v1/books/search?q=...
