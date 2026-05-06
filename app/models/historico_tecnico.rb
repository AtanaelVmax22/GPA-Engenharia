class HistoricoTecnico < ApplicationRecord
  belongs_to :condominio
  belongs_to :equipamento, optional: true
  belongs_to :user

  enum :tipo, { preventiva: 0, corretiva: 1, instalacao: 2, inspecao: 3 }, default: :corretiva
  enum :status, { concluido: 0, em_andamento: 1, pendente: 2 }, default: :concluido

  has_many_attached :fotos

  validates :titulo, :descricao, :data_atendimento, presence: true

  scope :recentes, -> { order(data_atendimento: :desc) }
end
