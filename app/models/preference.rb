class Preference
  include Dynamoid::Document

  belongs_to :user

  field :favorite_genres, :array, default: []
  field :favorite_authors, :array, default: []
  field :favorite_books, :array, default: []

  validates :user_id, presence: true
  validate :max_array_length

  private

  def max_array_length
    errors.add(:favorite_genres, "Máximo 10 géneros") if favorite_genres.size > 10
    errors.add(:favorite_authors, "Máximo 15 autores") if favorite_authors.size > 15
    errors.add(:favorite_books, "Máximo 20 libros") if favorite_books.size > 20
  end
end
