class Book
  include Dynamoid::Document

  field :id, :string
  field :title, :string
  field :authors, :array
  field :description, :string
  field :publish_date, :date
  field :number_of_pages, :integer
  field :isbn, :array
  field :cover_url, :string
  field :genres, :array

  global_secondary_index hash_key: :id

  validates_presence_of :id, :title
end
