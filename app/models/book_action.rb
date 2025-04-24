class BookAction
  # include Dynamoid::Document
  include Mongoid::Document
  include Mongoid::Timestamps

  # Constantes para estados y acciones
  STATUSES = {
    want_to_read: 1,
    reading: 2,
    finished: 3,
    dropped: 4
  }.freeze

  SWIPE_ACTIONS = %w[left right].freeze

 # Campos
 field :user_id, type: BSON::ObjectId
  field :book_id, type: BSON::ObjectId
  field :status, type: Integer
  field :swipe_action, type: String
  field :interacted_at, type: DateTime
  field :metadata, type: Hash

  # Validaciones actualizadas
  validates :user_id, :book_id, presence: true
  validates :swipe_action, inclusion: { in: SWIPE_ACTIONS }  # <-- Usa la constante
  validates :status, inclusion: { in: STATUSES.values }, allow_nil: true  # <-- .values

  # Callbacks
  before_save :set_interacted_at
  before_validation :validate_swipe_logic

  # Métodos
  def self.user_actions_for_book(user_id, book_id)
    where(user_id: user_id, book_id: book_id).first
  end

  def status_name
    STATUSES.key(status)
  end

  def status_name=(name)
    self.status = STATUSES[name.to_sym]
  end

  private

  def set_interacted_at
    self.interacted_at ||= Time.current
  end

  def validate_swipe_logic
    if swipe_action == "left"
      self.status = nil
    elsif swipe_action == "right"
      # Usa el valor numérico de la constante
      self.status ||= STATUSES[:want_to_read]  # <-- Corregido aquí
    end
  end
end
