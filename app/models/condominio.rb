
class Condominio < ApplicationRecord
  enum :status, {
    ativo: 0,
    inativo: 1
  }, default: :ativo

  has_many :equipamentos, dependent: :destroy
  has_many :historico_tecnicos, dependent: :destroy
  has_many :post_tecnicos, dependent: :destroy
  has_many :checklists, dependent: :destroy

  has_many_attached :fotos

  # Cada condomínio possui um único local
  # correspondente no módulo de estoque.
  has_one :local_estoque,
    class_name: "Estoque::Local",
    foreign_key: :condominio_id,
    inverse_of: :condominio,
    dependent: :restrict_with_error

  validates :nome, :endereco, :cidade, presence: true

  has_many :condominio_tecnicos,
  dependent: :destroy

  has_many :tecnicos_autorizados,
  through: :condominio_tecnicos,
  source: :user

  # Cria automaticamente o local de estoque
  # quando um novo condomínio é cadastrado.
  after_create :criar_local_de_estoque!

  def endereco_completo
    "#{endereco}, #{bairro} - #{cidade}/#{estado}"
  end

  def ultima_visita
    historico_tecnicos
      .order(data_atendimento: :desc)
      .first
      &.data_atendimento
  end

  private

  def criar_local_de_estoque!
    create_local_estoque!(
      nome: "Condomínio - #{nome}",
      tipo: :condominio,
      endereco: endereco,
      bairro: bairro,
      cidade: cidade,
      ativo: ativo?
    )
  end
end
