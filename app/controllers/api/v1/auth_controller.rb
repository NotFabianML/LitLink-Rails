# module Api::V1
#   class AuthController < ApplicationController
#     include Devise::Controllers::Helpers

#     skip_before_action only: [ :login, :signup ]

#     def signup
#       user = User.new(user_params)
#       if user.save
#         render json: { message: "Usuario creado exitosamente" }, status: :created
#       else
#         render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
#       end
#     end

#     def login
#       user = User.find_by(email: params[:email])
#       if user&.valid_password?(params[:password])
#         token = user.generate_jwt
#         render json: { token: token }
#       else
#         render json: { error: "Credenciales inválidas" }, status: :unauthorized
#       end
#     end

#     private

#     def user_params
#       params.require(:user).permit(:first_name, :last_name, :email, :password)
#     end
#   end
# end


module Api::V1
  class AuthController < ApplicationController
    # Saltamos la autenticación para login y signup
    # skip_before_action :authenticate_user!, only: [:login, :signup]

    def signup
      @user = User.new(user_params)
      if @user.save
        render json: { message: "Usuario creado exitosamente" }, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def login
      @user = User.find_by(email: params[:email])
      if @user && @user.valid_password?(params[:password])
        # Login "falso": solo verificamos que exista el usuario y la contraseña sea válida.
        render json: { message: "Login exitoso", user: @user.as_json(only: [ :id, :first_name, :last_name, :email ]) }
      else
        render json: { error: "Credenciales inválidas" }, status: :unauthorized
      end
    end

    private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end
  end
end
