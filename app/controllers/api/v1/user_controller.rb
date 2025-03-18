# module Api::V1
#   class UsersController < ApplicationController
#     before_action :authenticate_user!

#     def show
#       render json: current_user.as_json(
#         include: [ :user_genres, :user_authors, :user_book_preferences ]
#       )
#     end

#     def update_profile
#       if current_user.update(user_update_params)
#         render json: current_user
#       else
#         render json: { errors: current_user.errors }, status: :unprocessable_entity
#       end
#     end

#     private

#     def user_update_params
#       params.require(:user).permit(:first_name, :last_name)
#     end
#   end
# end


# module Api
#   class UsersController < ApplicationController
#     before_action :authenticate_user!, except: [ :create ]
#     before_action :set_user, only: [ :show, :update, :destroy ]

#     # GET /api/users
#     def index
#       @users = User.all
#       render json: @users
#     end

#     # GET /api/users/:id
#     def show
#       authorize_user!
#       render json: @user
#     end

#     # POST /api/users
#     def create
#       @user = User.new(user_params)

#       if @user.save
#         render json: @user, status: :created
#       else
#         render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
#       end
#     end

#     # PATCH/PUT /api/users/:id
#     def update
#       authorize_user!
#       if @user.update(user_params)
#         render json: @user
#       else
#         render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
#       end
#     end

#     # DELETE /api/users/:id
#     def destroy
#       authorize_user!
#       @user.destroy
#       head :no_content
#     end

#     private

#     def set_user
#       @user = User.find(params[:id])
#     rescue Dynamoid::Errors::RecordNotFound
#       render json: { error: "User not found" }, status: :not_found
#     end

#     def user_params
#       params.require(:user).permit(
#         :first_name,
#         :last_name,
#         :email,
#         :password
#       )
#     end

#     def authorize_user!
#       return if @user == current_user
#       render json: { error: "Unauthorized" }, status: :forbidden
#     end
#   end
# end


module Api
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :update, :destroy]

    # GET /api/users
    def index
      @users = User.all
      render json: @users
    end

    # GET /api/users/:id
    def show
      authorize_user!
      render json: @user
    end

    # POST /api/users
    def create
      @user = User.new(user_params)
      if @user.save
        render json: @user, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/users/:id
    def update
      authorize_user!
      if @user.update(user_params)
        render json: @user
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/users/:id
    def destroy
      authorize_user!
      @user.destroy
      head :no_content
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue Dynamoid::Errors::RecordNotFound
      render json: { error: "User not found" }, status: :not_found
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end

    def authorize_user!
      return if @user == current_user
      render json: { error: "Unauthorized" }, status: :forbidden
    end
  end
end
