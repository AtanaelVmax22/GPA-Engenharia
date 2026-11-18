
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

    belongs_to :origem_local,
      class_name: "Estoque::Local",
      optional: true

    belongs_to :destino_local,
      class_name: "Estoque::Local",
      optional: true

    belongs_to :user

    belongs_to :recebido_por,
      class_name: "User",
      optional: true

      has_many :movimentacao_itens,
      class_name: "Estoque::MovimentacaoItem",
      foreign_key: :movimentacao_id,
      inverse_of: :movimentacao,
      dependent: :destroy

      has_many :itens,
      through: :movimentacao_itens,
      source: :item

    # =========================================
    # VALIDACOES GERAIS
    # =========================================

    validates :tipo, presence: true

    validates :quantidade,
      presence: true,
      numericality: {
        greater_than_or_equal_to: 0
      }

    # =========================================
    # VALIDACOES DE MOVIMENTACAO
    # =========================================

    validate :validar_locais_da_movimentacao

    private

    def validar_locais_da_movimentacao
      return if tipo.blank?

      case tipo
      when "transferencia", "devolucao"
        validar_origem_e_destino

      when "entrada"
        if destino_local_id.blank?
          errors.add(
            :destino_local,
            "deve ser informado para uma entrada."
          )
        end

      when "saida", "perda", "defeito", "uso_servico"
        if origem_local_id.blank?
          errors.add(
            :origem_local,
            "deve ser informado para esta movimentação."
          )
        end

      when "ajuste", "inventario"
        if destino_local_id.blank?
          errors.add(
            :destino_local,
            "deve ser informado para ajuste ou inventário."
          )
        end
      end
    end

    def validar_origem_e_destino
      if origem_local_id.blank?
        errors.add(
          :origem_local,
          "deve ser informado para a transferência."
        )
      end

      if destino_local_id.blank?
        errors.add(
          :destino_local,
          "deve ser informado para a transferência."
        )
      end

      return if origem_local_id.blank? ||
                destino_local_id.blank?

      if origem_local_id.to_i == destino_local_id.to_i
        errors.add(
          :destino_local,
          "não pode ser igual ao estoque de origem."
        )
      end
    end
  end
end
