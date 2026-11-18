
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

    belongs_to :produto,
      class_name: "Estoque::Produto"

    belongs_to :local,
      class_name: "Estoque::Local",
      optional: true

      belongs_to :instalado_por,
        class_name: "User",
         optional: true

      has_many :movimentacao_itens,
       class_name: "Estoque::MovimentacaoItem",
       foreign_key: :item_id,
       inverse_of: :item,
       dependent: :restrict_with_error

      has_many :movimentacoes,
      through: :movimentacao_itens,
       source: :movimentacao

    before_validation :normalizar_identificadores

    validates :produto, presence: true
    validates :status, presence: true

    validates :codigo_patrimonio,
      uniqueness: { case_sensitive: false },
      allow_blank: true

    validates :numero_serie,
      uniqueness: { case_sensitive: false },
      allow_blank: true

    validates :mac,
      uniqueness: { case_sensitive: false },
      allow_blank: true

    validates :mac,
      format: {
        with: /\A(?:[0-9A-F]{2}:){5}[0-9A-F]{2}\z/,
        message: "deve conter 12 dígitos hexadecimais (ex.: AA:BB:CC:DD:EE:FF)"
      },
      allow_blank: true

    validates :garantia_loja_dias,
      numericality: {
        only_integer: true,
        greater_than_or_equal_to: 0
      },
      allow_nil: true

    validates :garantia_fabrica_meses,
      numericality: {
        only_integer: true,
        greater_than_or_equal_to: 0
      },
      allow_nil: true

    scope :recentes, -> { order(created_at: :desc) }

    # ==========================================
    # GARANTIAS
    # ==========================================

    def garantia_loja_vence_em
      return nil if data_compra.blank?
      return nil if garantia_loja_dias.blank?
      return nil if garantia_loja_dias <= 0

      data_compra + garantia_loja_dias.days
    end

    def garantia_fabrica_vence_em
      return nil if data_compra.blank?
      return nil if garantia_fabrica_meses.blank?
      return nil if garantia_fabrica_meses <= 0

      data_compra + garantia_fabrica_meses.months
    end

    def garantia_loja_ativa?
      vencimento = garantia_loja_vence_em
      vencimento.present? && vencimento >= Date.current
    end

    def garantia_fabrica_ativa?
      vencimento = garantia_fabrica_vence_em
      vencimento.present? && vencimento >= Date.current
    end

    def em_alguma_garantia?
      garantia_loja_ativa? || garantia_fabrica_ativa?
    end

    def garantia_loja_status
      return "Sem data de compra" if data_compra.blank?

      vencimento = garantia_loja_vence_em
      return "Garantia não informada" if vencimento.nil?

      if garantia_loja_ativa?
        "Ativa até #{vencimento.strftime('%d/%m/%Y')}"
      else
        "Vencida em #{vencimento.strftime('%d/%m/%Y')}"
      end
    end

    def garantia_fabrica_status
      return "Sem data de compra" if data_compra.blank?

      vencimento = garantia_fabrica_vence_em
      return "Garantia não informada" if vencimento.nil?

      if garantia_fabrica_ativa?
        "Ativa até #{vencimento.strftime('%d/%m/%Y')}"
      else
        "Vencida em #{vencimento.strftime('%d/%m/%Y')}"
      end
    end

    # ==========================================
    # IDENTIFICAÇÃO
    # ==========================================

    def identificacao
      codigo_patrimonio.presence ||
        numero_serie.presence ||
        mac.presence ||
        "Item ##{id || 'novo'}"
    end

    private

    def normalizar_identificadores
      self.codigo_patrimonio = normalizar_texto(codigo_patrimonio)
      self.numero_serie = normalizar_texto(numero_serie)
      self.mac = normalizar_mac(mac)
    end

    def normalizar_texto(valor)
      texto = valor.to_s.strip
      return nil if texto.blank?

      texto.upcase
    end

    def normalizar_mac(valor)
      texto = valor.to_s.strip.upcase
      return nil if texto.blank?

      # Aceita dois-pontos, hífens, pontos ou MAC sem separadores.
      # Caracteres inesperados não são descartados silenciosamente.
      return texto unless texto.match?(/\A[0-9A-F.:\-\s]+\z/)

      hexadecimal = texto.gsub(/[^0-9A-F]/, "")

      # Se for inválido, a validação de formato apresentará o erro.
      return texto unless hexadecimal.length == 12

      hexadecimal.scan(/../).join(":")
    end
  end
end
