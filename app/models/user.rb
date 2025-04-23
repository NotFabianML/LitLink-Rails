class User
  # include Dynamoid::Document

  #  attr_accessor :password  # <-- Atributo virtual

  # table name: :users,
  #       key: :id,
  #       global_secondary_indexes: {
  #         email_index: {
  #           hash_key: :email,
  #           projection: :all
  #         }
  #       }
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :password_digest, type: String

  has_secure_password

  validate :email_uniqueness
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record? || changes[:password_digest] }

  before_save :encrypt_password  # <-- Callback para encriptar

  def self.find_by_email(email)
    find_by(email: email)
  end

  def authenticate(raw_password)
    BCrypt::Password.new(password_digest) == raw_password rescue false
  end

  def generate_jwt
    JwtService.encode(user_id: id)
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def encrypt_password
    return if password.blank?
    self.password_digest = BCrypt::Password.create(password)
  end

  def email_uniqueness
    return unless email.present?

    begin
      existing_user = User.where(email: email).first
    rescue => e
      Rails.logger.error "Error checking email uniqueness: #{e.message}"
      return
    end

    if existing_user && existing_user.id != id
      errors.add(:email, "ya está en uso")
    end
  end
end
