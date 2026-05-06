class Equipamento < ApplicationRecord
  belongs_to :condominio

  enum :status, { operacional: 0, manutencao: 1, inativo: 2 }, default: :operacional

  CATEGORIAS = [
    "Portão Veicular", "Portão Social", "Interfone", "Câmera CFTV",
    "Controle de Acesso", "Fechadura Eletrônica", "Central Eletrônica",
    "Sensor", "Motor", "Iluminação", "Outro"
  ].freeze

  has_many :historico_tecnicos, dependent: :destroy
  has_many_attached :fotos

  validates :nome, :categoria, :condominio, presence: true
end
