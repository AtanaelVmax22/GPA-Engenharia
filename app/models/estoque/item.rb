module Estoque
  class Item < ApplicationRecord
    self.table_name = "estoque_itens"

    enum :status, {
      em_estoque: 0,
      instalado: 1,
      em_garantia: 2,
      enviado_para_troca: 3,
      substituido: 4,
      perdido: 5,
      baixado: 6
    }

    has_many :itens,
    class_name: "Estoque::Item",
    foreign_key: :local_id,
    dependent: :nullify

    has_many :itens,
    class_name: "Estoque::Item",
    foreign_key: :produto_id,
    dependent: :destroy

    belongs_to :produto, class_name: "Estoque::Produto"
    belongs_to :local, class_name: "Estoque::Local", optional: true

    validates :produto, presence: true
    validates :status, presence: true

    validates :codigo_patrimonio, uniqueness: true, allow_blank: true
    validates :numero_serie, uniqueness: true, allow_blank: true
    validates :mac, uniqueness: true, allow_blank: true

    def garantia_loja_vence_em
      return nil if data_compra.blank?

      data_compra + garantia_loja_dias.days
    end

    def garantia_fabrica_vence_em
      return nil if data_compra.blank?

      data_compra + garantia_fabrica_meses.months
    end

    def garantia_loja_ativa?
      garantia_loja_vence_em.present? && garantia_loja_vence_em >= Date.current
    end

    def garantia_fabrica_ativa?
      garantia_fabrica_vence_em.present? && garantia_fabrica_vence_em >= Date.current
    end

    def em_alguma_garantia?
      garantia_loja_ativa? || garantia_fabrica_ativa?
    end

    def garantia_loja_status
      return "Sem data de compra" if data_compra.blank?
      return "Ativa até #{garantia_loja_vence_em.strftime("%d/%m/%Y")}" if garantia_loja_ativa?

      "Vencida em #{garantia_loja_vence_em.strftime("%d/%m/%Y")}"
    end

    def garantia_fabrica_status
      return "Sem data de compra" if data_compra.blank?
      return "Ativa até #{garantia_fabrica_vence_em.strftime("%d/%m/%Y")}" if garantia_fabrica_ativa?

      "Vencida em #{garantia_fabrica_vence_em.strftime("%d/%m/%Y")}"
    end

    def identificacao
      codigo_patrimonio.presence ||
        numero_serie.presence ||
        mac.presence ||
        "Item ##{id}"
    end
  end
end