module Api::V1
  class PreferencesController < ApplicationController
    before_action :authenticate_user!

    def show
      preference = current_user.preference || current_user.create_preference
      render json: preference
    end

    def update
      preference = current_user.preference || current_user.build_preference
      if preference.update(preference_params)
        render json: preference
      else
        render json: { errors: preference.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def preference_params
      params.require(:preference).permit(
        favorite_genres: [],
        favorite_authors: [],
        favorite_books: []
      )
    end
  end
end
