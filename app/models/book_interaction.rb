class BookInteraction
  include Dynamoid::Document

  module Status
    WANT_TO_READ = 1
    READING = 2
    READ = 3
    DISLIKED = 4
  end

  field :user_id, :string
  field :book_id, :string
  field :status, :integer
  field :swiped_at, :datetime

  validates_presence_of :user_id, :book_id
  validates :status, inclusion: { in: Status.constants.map { |c| Status.const_get(c) } }

  global_secondary_index hash_key: :user_id
  global_secondary_index hash_key: :book_id
end
