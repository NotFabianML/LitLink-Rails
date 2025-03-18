class BookAction
  include Dynamoid::Document

  # Constantes para estados y acciones
  STATUSES = {
    want_to_read: 1,
    reading: 2,
    finished: 3,
    dropped: 4
  }.freeze

  SWIPE_ACTIONS = %w[left right].freeze

  # Schema DynamoDB con índices críticos
  table name: :book_actions,
        key: :id,
        global_secondary_indexes: [
          {
            hash_key: :user_id,
            range_key: :book_id,
            name: "user_book_index",
            projection: :all
          },
          {
            hash_key: :user_id,
            range_key: :interacted_at,
            name: "user_interaction_timeline",
            projection: :all
          }
        ]

  # Campos
  field :user_id, :string
  field :book_id, :string
  field :status, :integer
  field :swipe_action, :string
  field :interacted_at, :datetime
  field :metadata, :raw

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
