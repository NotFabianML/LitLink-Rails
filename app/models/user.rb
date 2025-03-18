class User
  extend Devise::Models
  include Dynamoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable
  include Dynamoid::Document
  include Devise::JWT::RevocationStrategies::JTIMatcher

  field :first_name, :string
  field :last_name, :string
  field :email, :string
  field :encrypted_password, :string

  field :jti, :string

  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_one :preference
  has_many :book_interactions

  # Agregamos validaciones manualmente
  validates :first_name, :last_name, :email, presence: true
  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
end
