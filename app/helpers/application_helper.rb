module ApplicationHelper
  include Pagy::Frontend

  def nav_link(label, path, icon: nil)
    active = request.path.start_with?(path) && (path != root_path)
    classes = active ?
      "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium bg-amber-500/10 text-amber-400 border border-amber-500/20" :
      "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-zinc-400 hover:text-zinc-100 hover:bg-zinc-800 transition-colors"
    link_to path, class: classes do
      content_tag(:span, icon, class: "text-base w-5 text-center") +
      content_tag(:span, label)
    end
  end

  def status_badge(status)
    colors = {
      "ativo" => "bg-emerald-900/50 text-emerald-400 border-emerald-700",
      "inativo" => "bg-red-900/50 text-red-400 border-red-700",
      "operacional" => "bg-emerald-900/50 text-emerald-400 border-emerald-700",
      "manutencao" => "bg-amber-900/50 text-amber-400 border-amber-700",
      "concluido" => "bg-emerald-900/50 text-emerald-400 border-emerald-700",
      "em_andamento" => "bg-blue-900/50 text-blue-400 border-blue-700",
      "pendente" => "bg-red-900/50 text-red-400 border-red-700",
    }
    labels = {
      "ativo" => "Em dia", "inativo" => "Inativo", "operacional" => "Operacional",
      "manutencao" => "Manutenção", "concluido" => "Concluído",
      "em_andamento" => "Em andamento", "pendente" => "Pendente"
    }
    css = colors[status.to_s] || "bg-zinc-800 text-zinc-400 border-zinc-700"
    label = labels[status.to_s] || status.to_s.humanize
    content_tag(:span, label, class: "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium border #{css}")
  end

  def tipo_badge(tipo)
    colors = {
      "preventiva" => "bg-blue-900/50 text-blue-400 border-blue-700",
      "corretiva" => "bg-red-900/50 text-red-400 border-red-700",
      "instalacao" => "bg-purple-900/50 text-purple-400 border-purple-700",
      "inspecao" => "bg-amber-900/50 text-amber-400 border-amber-700",
    }
    labels = {
      "preventiva" => "Preventiva", "corretiva" => "Corretiva",
      "instalacao" => "Instalação", "inspecao" => "Inspeção"
    }
    css = colors[tipo.to_s] || "bg-zinc-800 text-zinc-400 border-zinc-700"
    label = labels[tipo.to_s] || tipo.to_s.humanize
    content_tag(:span, label, class: "inline-flex items-center px-2 py-0.5 rounded text-xs font-medium border #{css}")
  end
end
