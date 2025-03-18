module Api::V1
  class UsersController < ApplicationController
    # before_action :set_user, only: [:show, :update, :destroy]
    skip_before_action :authenticate_user!, only: [ :index, :show ]

    # GET /api/v1/users
    def index
      @users = User.all
      render json: @users
    end

    # GET /api/v1/users/:id
    def show
      @user = User.find(params[:id])
      render json: @user
    rescue Dynamoid::Errors::RecordNotFound
      render json: { error: "Usuario no encontrado" }, status: :not_found
    end

    # PATCH/PUT /api/v1/users/:id
    def update
      if @user.update(user_params)
        render json: @user
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/users/:id
    def destroy
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
      params.permit(:first_name, :last_name, :email)
    end
  end
end
