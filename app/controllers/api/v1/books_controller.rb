module Api::V1
  class BooksController < ApplicationController
    before_action :authenticate_user!

    def recommendations
      # Lógica de recomendaciones (puedes implementar según preferencias)
      recommended_books = BookRecommendationService.new(current_user).call
      render json: recommended_books
    end

    def search
      books = OpenLibraryService.search(params[:query])
      render json: books
    end

    private

    def search_params
      params.permit(
        liked_books: [],
        authors: [],
        genres: []
      ).to_h.symbolize_keys
    end
  end
end
