class Preference
  include Dynamoid::Document

  table name: :preferences, key: :id, capacity_mode: :on_demand

  field :user_id, :string
  field :favorite_genres, :array, of: :string
  field :favorite_authors, :array, of: :string
  field :favorite_books, :array, of: :string

  belongs_to :user

  validates :user_id, presence: true
end
