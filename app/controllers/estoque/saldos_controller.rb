module Estoque
  class SaldosController < BaseController
    def index
      saldos_scope = Saldo
        .includes(:produto, :local)
        .order("estoque_produtos.nome ASC, estoque_locais.nome ASC")

      @saldos_pagination = helpers.pagination_metadata(
        saldos_scope,
        page: params[:page].presence || 1,
        per_page: 15
      )

      @saldos = @saldos_pagination[:records]
    end

    def consulta
      produto_id = params[:produto_id]
      local_id = params[:local_id]

      saldo = Saldo.find_by(produto_id: produto_id, local_id: local_id)

      quantidade = saldo&.quantidade || 0

      render json: {
        quantidade: quantidade.to_f,
        quantidade_formatada: helpers.formatar_quantidade(quantidade)
      }
    end
  end
end