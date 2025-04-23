module Api::V1
  class AuthController < ApplicationController
    skip_before_action :authenticate_user!, only: [ :login, :signup, :me ]

    # POST /api/v1/auth/signup
    def signup
       user = User.new(user_params)

      if user.save
        token = user.generate_jwt
        render json: { token: token, user: user }, status: :created
      else
        render json: { errors: user.errors }, status: :unprocessable_entity
      end
    end

    # POST /api/v1/auth/login
    def login
      # Acceder directamente a los parámetros raíz
      email = params[:email]
      password = params[:password]

      unless email.present? && password.present?
        return render json: { error: "Email y contraseña requeridos" }, status: :bad_request
      end

      user = User.find_by_email(email)

      if user&.authenticate(password)
        token = user.generate_jwt
        render json: { token: token, user: user }
      else
        render json: { error: "Invalid credentials" }, status: :unauthorized
      end
    end

    # GET /api/v1/auth/me
    def me
      render json: current_user, status: :ok
    end

    private

    def user_params
      # params.require(:auth).permit(
      #   user: [ :first_name, :last_name, :email, :password ]
      # )[:user]
      params.require(:auth).require(:user).permit(
      :first_name, :last_name, :email, :password, :password_confirmation
      )
    end
  end
end
