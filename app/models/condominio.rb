class Condominio < ApplicationRecord
  enum :status, { ativo: 0, inativo: 1 }, default: :ativo

  has_many :equipamentos, dependent: :destroy
  has_many :historico_tecnicos, dependent: :destroy
  has_many :post_tecnicos, dependent: :destroy
  has_many :checklists, dependent: :destroy
  has_many_attached :fotos

  validates :nome, :endereco, :cidade, presence: true

  def endereco_completo
    "#{endereco}, #{bairro} - #{cidade}/#{estado}"
  end

  def ultima_visita
    historico_tecnicos.order(data_atendimento: :desc).first&.data_atendimento
  end
end
