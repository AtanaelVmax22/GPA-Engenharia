module Estoque
  class Local < ApplicationRecord
    self.table_name = "estoque_locais"

    enum :tipo, {
      central: 0,
      regional: 1,
      tecnico: 2,
      veiculo: 3,
      obra: 4,
      condominio: 5,
      descarte: 6
    }

    belongs_to :responsavel, class_name: "User", optional: true

    has_many :saldos, class_name: "Estoque::Saldo", dependent: :destroy
    has_many :movimentacoes_origem,
             class_name: "Estoque::Movimentacao",
             foreign_key: :origem_local_id,
             dependent: :restrict_with_error

    has_many :movimentacoes_destino,
             class_name: "Estoque::Movimentacao",
             foreign_key: :destino_local_id,
             dependent: :restrict_with_error

    before_validation :generate_qr_token, on: :create

    validates :nome, presence: true
    validates :tipo, presence: true
    validates :qr_token, presence: true, uniqueness: true

    scope :ativos, -> { where(ativo: true) }

    private

    def generate_qr_token
      self.qr_token ||= SecureRandom.hex(16)
    end
  end
end