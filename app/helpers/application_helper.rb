
module ApplicationHelper
  include Pagy::Frontend

  # ==========================================
  # NAVEGAÇÃO
  # ==========================================

  def nav_link(label, path, icon: nil)
    normalized_path = path.to_s.sub(%r{/$}, "")

    active =
      request.path == path ||
      (
        normalized_path.present? &&
        normalized_path != "/" &&
        request.path.start_with?("#{normalized_path}/")
      )

    classes = [
      "gpa-nav-link",
      ("is-active" if active)
    ].compact.join(" ")

    link_to path,
      class: classes,
      title: label,
      aria: { current: (active ? "page" : nil) } do

      icon_html =
        if icon.present?
          content_tag(
            :span,
            icon,
            class: "gpa-nav-legacy-icon",
            aria: { hidden: true }
          )
        else
          "".html_safe
        end

      icon_html + content_tag(
        :span,
        label,
        class: "gpa-nav-label"
      )
    end
  end

  # ==========================================
  # BADGES DE STATUS
  # ==========================================

  def status_badge(status)
    key = status.to_s

    labels = {
      "ativo" => "Em dia",
      "inativo" => "Inativo",
      "operacional" => "Operacional",
      "manutencao" => "Manutenção",
      "concluido" => "Concluído",
      "em_andamento" => "Em andamento",
      "pendente" => "Pendente"
    }

    variants = {
      "ativo" => "success",
      "inativo" => "danger",
      "operacional" => "success",
      "manutencao" => "warning",
      "concluido" => "success",
      "em_andamento" => "info",
      "pendente" => "danger"
    }

    label = labels.fetch(
      key,
      key.present? ? key.humanize : "Não informado"
    )

    variant = variants.fetch(key, "neutral")

    gpa_badge(label, variant: variant)
  end

  # ==========================================
  # BADGES DE TIPOS TÉCNICOS
  # ==========================================

  def tipo_badge(tipo)
    key = tipo.to_s

    labels = {
      "preventiva" => "Preventiva",
      "corretiva" => "Corretiva",
      "instalacao" => "Instalação",
      "inspecao" => "Inspeção"
    }

    variants = {
      "preventiva" => "info",
      "corretiva" => "danger",
      "instalacao" => "purple",
      "inspecao" => "warning"
    }

    label = labels.fetch(
      key,
      key.present? ? key.humanize : "Não informado"
    )

    variant = variants.fetch(key, "neutral")

    gpa_badge(label, variant: variant)
  end

  # ==========================================
  # COMPONENTE GLOBAL DE BADGE
  # ==========================================

  def gpa_badge(label, variant: "neutral", dot: true)
    allowed_variants = %w[
      success
      danger
      warning
      info
      purple
      neutral
    ]

    variant = variant.to_s

    variant = "neutral" unless allowed_variants.include?(variant)

    content_tag(
      :span,
      class: "gpa-badge gpa-badge-#{variant}",
      title: label.to_s
    ) do

      indicator =
        if dot
          content_tag(
            :span,
            "",
            class: "gpa-badge-dot",
            aria: { hidden: true }
          )
        else
          "".html_safe
        end

      indicator + ERB::Util.html_escape(label.to_s)
    end
  end
end
