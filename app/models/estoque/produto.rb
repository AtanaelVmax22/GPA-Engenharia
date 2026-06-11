module Estoque
  class Produto < ApplicationRecord
    self.table_name = "estoque_produtos"

    belongs_to :created_by, class_name: "User", optional: true

    has_many :saldos, class_name: "Estoque::Saldo", dependent: :destroy
    has_many :movimentacoes, class_name: "Estoque::Movimentacao", dependent: :restrict_with_error

    before_validation :generate_qr_token, on: :create

    validates :nome, presence: true
    validates :unidade_medida, presence: true
    validates :qr_token, presence: true, uniqueness: true
    validates :estoque_minimo, numericality: { greater_than_or_equal_to: 0 }

    scope :ativos, -> { where(ativo: true) }

    private

    def generate_qr_token
      self.qr_token ||= SecureRandom.hex(16)
    end
  end
end