module Estoque
  class Movimentacao < ApplicationRecord
    self.table_name = "estoque_movimentacoes"

    enum :tipo, {
      entrada: 0,
      saida: 1,
      transferencia: 2,
      ajuste: 3,
      devolucao: 4,
      perda: 5,
      defeito: 6,
      uso_servico: 7,
      inventario: 8
    }

    enum :status_recebimento, {
      nao_aplicavel: 0,
      pendente: 1,
      recebido: 2,
      recusado: 3
    }

    belongs_to :produto, class_name: "Estoque::Produto"
    belongs_to :origem_local, class_name: "Estoque::Local", optional: true
    belongs_to :destino_local, class_name: "Estoque::Local", optional: true
    belongs_to :user
    belongs_to :recebido_por, class_name: "User", optional: true

    validates :tipo, presence: true
    validates :quantidade, numericality: { greater_than_or_equal_to: 0 }
  end
end 