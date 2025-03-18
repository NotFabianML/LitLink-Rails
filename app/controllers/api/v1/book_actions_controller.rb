# app/controllers/api/v1/book_actions_controller.rb
module Api::V1
  class BookActionsController < ApplicationController
    # skip_before_action :authenticate_user!, only: [ :show, :update, :destroy ]
    before_action :set_book_action, only: [ :show, :update, :destroy ]

    # GET /api/v1/users/book_actions
    def index
      @actions = BookAction.where(user_id: current_user.id)
                   .order(interacted_at: :desc)
      render json: @actions.map { |a| format_action(a) } # ← Formatea para frontend
    end

    # GET /api/v1/users/:user_id/book_actions/:id
    def show
      render json: @book_action
    end

    # POST /api/v1/users/book_actions
    def create
      existing_action = BookAction.user_actions_for_book(
        current_user.id,
        params[:book_id]
      )

      return render_conflict if existing_action

      book_data = OpenLibraryService.get_book(params[:book_id])
      return render_book_not_found unless book_data

      @book_action = BookAction.new(
        book_action_params.merge(
          user_id: current_user.id,
          metadata: book_data,
          status: status_to_integer(params[:status]) # ← Convierte string a integer
        )
      )

      if @book_action.save
        render json: format_action(@book_action), status: :created
      else
        render json: { errors: @book_action.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/users/:user_id/book_actions/:id
    def update
      if @book_action.update(book_action_params)
        render json: @book_action
      else
        render json: { errors: @book_action.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/users/:user_id/book_actions/:id
    def destroy
      @book_action.destroy
      head :no_content
    end

    private

    def format_action(action)
      {
        id: action.id,
        book_id: action.book_id,
        swipe_action: action.swipe_action,
        status: BookAction::STATUSES.key(action.status), # ← Nombre legible
        interacted_at: action.interacted_at,
        metadata: action.metadata
      }
    end

    def status_to_integer(status_param)
      return BookAction::STATUSES[:want_to_read] if status_param.blank?
      BookAction::STATUSES[status_param.to_sym] || nil
    end

    def set_book_action
      @book_action = BookAction.find(params[:id])
    rescue Dynamoid::Errors::RecordNotFound
      render json: { error: "Acción no encontrada" }, status: :not_found
    end

    def book_action_params
      params.permit(:book_id, :status, :swipe_action)
    end

    def render_book_not_found
      render json: { error: "Libro no encontrado en OpenLibrary" }, status: :unprocessable_entity
    end

    def render_unauthorized
      render json: { error: "No autorizado" }, status: :unauthorized
    end
  end
end
