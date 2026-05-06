class PostTecnico < ApplicationRecord
  belongs_to :user
  belongs_to :condominio, optional: true

  has_many :comentarios, dependent: :destroy
  has_many :curtidas, dependent: :destroy
  has_many_attached :fotos

  validates :conteudo, presence: true

  scope :recentes, -> { order(created_at: :desc) }

  def curtido_por?(user)
    curtidas.exists?(user: user)
  end
end
