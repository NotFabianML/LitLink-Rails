module Api::V1
  class PreferencesController < ApplicationController
    before_action :authenticate_user!
    before_action :load_preference, only: [ :show, :update, :destroy ]

    # GET /api/v1/preference
    def show
      if @preference
        render json: @preference
      else
        # Devuelve un objeto vacío de preferencias si aún no existe
        render json: {
          user_id:     current_user.id.to_s,
          favorite_genres:  [],
          favorite_authors: [],
          favorite_books:   []
        }
      end
    end

    # POST /api/v1/preference
    def create
      # Si ya existe, devolvemos conflict
      return render json: { error: "Ya existen preferencias" }, status: :conflict if @preference

      @preference = Preference.new(preference_params.merge(user_id: current_user.id))
      if @preference.save
        render json: @preference, status: :created
      else
        render json: { errors: @preference.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/v1/preference
    def update
      unless @preference
        return render json: { error: "No existe preferencia para actualizar" }, status: :not_found
      end

      if @preference.update(preference_params)
        render json: @preference
      else
        render json: { errors: @preference.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/preference
    def destroy
      unless @preference
        return head :no_content
      end

      @preference.destroy
      head :no_content
    end

    private

    # Carga la preferencia o deja @preference en nil en lugar de lanzar excepción
    def load_preference
      @preference = Preference.where(user_id: current_user.id).first
    end

    def preference_params
      params.permit(
        favorite_genres:  [],
        favorite_authors: [],
        favorite_books:   []
      )
    end
  end
end
