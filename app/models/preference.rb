class Preference
  # include Dynamoid::Document
  include Mongoid::Document

  # table name: :preferences, key: :id, capacity_mode: :on_demand

  # field :user_id, :string
  # field :favorite_genres, :array, of: :string
  # field :favorite_authors, :array, of: :string
  # field :favorite_books, :array, of: :string

  belongs_to :user
  field :favorite_genres, type: Array, default: []
  field :favorite_authors, type: Array, default: []
  field :favorite_books, type: Array, default: []

  validates :user_id, presence: true
end
