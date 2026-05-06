class PostTecnico < ApplicationRecord
  belongs_to :user
  belongs_to :condominio, optional: true

  has_many :comentarios, dependent: :destroy
  has_many :curtidas, dependent: :destroy
  has_many_attached :midias

  validates :conteudo, presence: true

  scope :recentes, -> { order(created_at: :desc) }

  def curtido_por?(user)
    curtidas.exists?(user: user)
  end

  def fotos
    midias.select { |m| m.content_type.start_with?("image/") }
  end

  def videos
    midias.select { |m| m.content_type.start_with?("video/") }
  end
end
