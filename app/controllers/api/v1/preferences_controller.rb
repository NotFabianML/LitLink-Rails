module Api::V1
  class PreferencesController < ApplicationController
    before_action :set_preference, only: [:show, :update, :destroy]

    # GET /api/v1/users/:user_id/preferences
    def show
      render json: @preference
    end

    # POST /api/v1/users/:user_id/preferences
    def create
      @preference = Preference.new(preference_params.merge(user_id: params[:user_id]))
      
      if @preference.save
        render json: @preference, status: :created
      else
        render json: { errors: @preference.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/users/:user_id/preferences
    def update
      if @preference.update(preference_params)
        render json: @preference
      else
        render json: { errors: @preference.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/users/:user_id/preferences
    def destroy
      @preference.destroy
      head :no_content
    end

    private

    def set_preference
      @preference = Preference.find_by(user_id: params[:user_id])
      render json: { error: "Preference not found" }, status: :not_found unless @preference
    end

    def preference_params
      params.permit(favorite_genres: [], favorite_authors: [], favorite_books: [])
    end
  end
end