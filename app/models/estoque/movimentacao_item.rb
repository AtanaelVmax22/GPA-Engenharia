
module Estoque
  class MovimentacaoItem < ApplicationRecord
    self.table_name = "estoque_movimentacao_itens"

    belongs_to :movimentacao,
      class_name: "Estoque::Movimentacao",
      inverse_of: :movimentacao_itens

    belongs_to :item,
      class_name: "Estoque::Item",
      inverse_of: :movimentacao_itens

    validates :item_id,
      uniqueness: {
        scope: :movimentacao_id,
        message: "já está associado a esta movimentação"
      }

    validate :produto_compativel

    private

    def produto_compativel
      return if item.blank? || movimentacao.blank?

      if item.produto_id != movimentacao.produto_id
        errors.add(
          :item,
          "não pertence ao produto desta movimentação"
        )
      end
    end
  end
end
