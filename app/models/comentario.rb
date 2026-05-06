class Comentario < ApplicationRecord
  belongs_to :post_tecnico
  belongs_to :user

  validates :conteudo, presence: true
end
