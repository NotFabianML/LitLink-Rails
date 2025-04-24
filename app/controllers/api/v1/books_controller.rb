module Api::V1
  class BooksController < ApplicationController
    def search
      # Obtener preferencias del usuario desde DB
      preferences = current_user.preference
      books = OpenLibraryService.search_books({
        favorite_books: preferences&.favorite_books,
        favorite_authors: preferences&.favorite_authors,
        favorite_genres: preferences&.favorite_genres
      })

      render json: books
    rescue => e
      render json: { error: "Error buscando libros: #{e.message}" }, status: :internal_server_error
    end

    # GET /api/v1/books/saved -> Libros guardados (swipe derecha)
    def saved
      saved_books = current_user.book_actions
                       .where(swipe_action: "right")
                       .map { |action| OpenLibraryService.get_book(action.book_id) }
                       .compact  # Eliminar nulos si hay errores

      render json: saved_books
    end

    def recommend
      prefs = current_user.preference
      books = OpenLibraryService.search_books(
        favorite_books:   prefs&.favorite_books,
        favorite_authors: prefs&.favorite_authors,
        favorite_genres:  prefs&.favorite_genres
      )
      render json: books
    rescue => e
      render json: { error: "Error recommending books: #{e.message}" }, status: :internal_server_error
    end
  end
end
