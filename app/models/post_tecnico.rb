class PostTecnico < ApplicationRecord
  belongs_to :user
  belongs_to :condominio, optional: true

  has_many :comentarios, dependent: :destroy
  has_many_attached :anexos

  validates :titulo, :conteudo, presence: true

  scope :recentes, -> { order(created_at: :desc) }
end
