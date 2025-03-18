module Api::V1
  class BookInteractionsController < ApplicationController
    before_action :authenticate_user!

    def create
      interaction = current_user.book_interactions.build(interaction_params)
      if interaction.save
        render json: interaction, status: :created
      else
        render json: { errors: interaction.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def index
      interactions = current_user.book_interactions
      render json: interactions
    end

    private

    def interaction_params
      params.require(:interaction).permit(:book_id, :status)
    end
  end
end
