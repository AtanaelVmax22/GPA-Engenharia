
module EstoqueHelper

  # ==========================================
  # STATUS DOS ITENS DO ESTOQUE
  # ==========================================

  STATUS_ITEM_LABELS = {
    "em_estoque" => "Em estoque",
    "instalado" => "Instalado",
    "em_garantia" => "Em garantia",
    "enviado_para_troca" => "Enviado para troca",
    "substituido" => "Substituído",
    "perdido" => "Perdido",
    "baixado" => "Baixado"
  }.freeze

  STATUS_ITEM_VARIANTS = {
    "em_estoque" => "success",
    "instalado" => "info",
    "em_garantia" => "warning",
    "enviado_para_troca" => "purple",
    "substituido" => "neutral",
    "perdido" => "danger",
    "baixado" => "neutral"
  }.freeze

  def status_item_label(status)
    key = status.to_s

    STATUS_ITEM_LABELS.fetch(
      key,
      key.present? ? key.humanize : "Não informado"
    )
  end

  # Método adicional para exibir status
  # do estoque com visual padronizado.
  def status_item_badge(status)
    key = status.to_s

    label = status_item_label(key)

    variant = STATUS_ITEM_VARIANTS.fetch(
      key,
      "neutral"
    )

    gpa_badge(label, variant: variant)
  end

  # ==========================================
  # GARANTIAS
  # ==========================================

  def garantia_badge(item)
    if item.data_compra.blank?
      gpa_badge(
        "Sem data de compra",
        variant: "neutral"
      )

    elsif item.em_alguma_garantia?
      gpa_badge(
        "Ativa",
        variant: "success"
      )

    else
      gpa_badge(
        "Vencida",
        variant: "danger"
      )
    end
  end

  # ==========================================
  # FORMATAÇÃO DE QUANTIDADES
  # ==========================================

  def formatar_quantidade(valor)
    numero = BigDecimal(valor.to_s)

    if numero.frac.zero?
      numero.to_i.to_s
    else
      numero.to_s("F")
        .sub(/0+\z/, "")
        .sub(/\.\z/, "")
    end
  end

end
