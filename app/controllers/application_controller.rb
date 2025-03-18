class ApplicationController < ActionController::API
   include Devise::Controllers::Helpers

  # Si deseas definir un método de autenticación básico:
  def authenticate_user!
    render json: { error: "Debes iniciar sesión" }, status: :unauthorized unless current_user
  end
end
