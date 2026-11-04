module Estoque
  class MovimentacoesController < BaseController
    def index
      movimentacoes_scope = Movimentacao
        .includes(:produto, :origem_local, :destino_local, :user)
        .order(created_at: :desc)

      @movimentacoes_pagination = helpers.pagination_metadata(
        movimentacoes_scope,
        page: params[:page].presence || 1,
        per_page: 15
      )

      @movimentacoes = @movimentacoes_pagination[:records]
    end

    def show
      @movimentacao = Movimentacao.find(params[:id])
    end

    def new
      carregar_dados_do_formulario
    end

    def create
      Estoque::MovimentacaoService.new(
        user: current_user,
        params: movimentacao_params
      ).call

      redirect_to estoque_movimentacoes_path, notice: "Movimentação registrada com sucesso."
    rescue ActiveRecord::RecordInvalid, ArgumentError => e
      carregar_dados_do_formulario
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end

    private

    def carregar_dados_do_formulario
      @produtos = Produto.ativos.order(:nome)
      @locais = Local.ativos.order(:nome)

      produto_id = params[:produto_id] || params.dig(:estoque_movimentacao, :produto_id)
      origem_local_id = params[:origem_local_id] || params.dig(:estoque_movimentacao, :origem_local_id)
      destino_local_id = params[:destino_local_id] || params.dig(:estoque_movimentacao, :destino_local_id)

      @produto_selecionado = Produto.find_by(id: produto_id) if produto_id.present?
      @origem_local_selecionado = Local.find_by(id: origem_local_id) if origem_local_id.present?
      @destino_local_selecionado = Local.find_by(id: destino_local_id) if destino_local_id.present?
    end

    def movimentacao_params
      params.require(:estoque_movimentacao).permit(
        :produto_id,
        :tipo,
        :quantidade,
        :origem_local_id,
        :destino_local_id,
        :observacao
      )
    end
  end
end