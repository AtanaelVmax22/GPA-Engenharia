module Estoque
  class NotificacoesController < BaseController
    def transferencias_pendentes
      scope = Movimentacao
        .includes(:produto, :origem_local, :destino_local, :user)
        .where(tipo: :transferencia, status_recebimento: :pendente)
        .order(created_at: :desc)
        .limit(10)

      unless current_user.admin?
        scope = scope.joins(:destino_local)
          .where(estoque_locais: { responsavel_id: current_user.id })
      end

      transferencias = scope.map do |mov|
        {
          id: mov.id,
          produto: mov.produto.nome,
          quantidade: helpers.formatar_quantidade(mov.quantidade),
          origem: mov.origem_local&.nome,
          destino: mov.destino_local&.nome,
          enviado_por: mov.user.nome.presence || mov.user.email,
          criado_em: mov.created_at.strftime("%d/%m/%Y %H:%M"),
          url: estoque_recebimento_path(mov),
          recebimentos_url: estoque_local_recebimentos_path(mov.destino_local)
        }
      end

      render json: {
        total: transferencias.size,
        transferencias: transferencias
      }
    end
  end
end