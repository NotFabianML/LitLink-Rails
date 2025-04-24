module Api::V1
  class AuthController < ApplicationController
    skip_before_action :authenticate_user!, only: [ :login, :signup, :me ]

    def signup
      user = User.new(user_params)
      if user.save
        render json: {
          token: user.generate_jwt,
          user: {
            id: user.id.to_s,
            first_name: user.first_name,
            last_name:  user.last_name,
            email:      user.email
          }
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def login
      user = User.find_by_email(params[:email])
      if user&.authenticate(params[:password])
        render json: {
          token: user.generate_jwt,
          user: {
            id: user.id.to_s,
            first_name: user.first_name,
            last_name:  user.last_name,
            email:      user.email
          }
        }
      else
        render json: { error: "Credenciales inválidas" }, status: :unauthorized
      end
    end

    # GET /api/v1/auth/me
    def me
      render json: current_user, status: :ok
    end

    private

    def user_params
      params.require(:auth).require(:user).permit(
      :first_name, :last_name, :email, :password, :password_confirmation
      )
    end
  end
end
