
module Estoque
  class MovimentacoesController < BaseController
    def index
      movimentacoes_scope = Movimentacao
        .includes(
          :produto,
          :origem_local,
          :destino_local,
          :user
        )
        .order(created_at: :desc)

      @movimentacoes_pagination =
        helpers.pagination_metadata(
          movimentacoes_scope,
          page: params[:page].presence || 1,
          per_page: 15
        )

      @movimentacoes =
        @movimentacoes_pagination[:records]
    end

    def show
      @movimentacao = Movimentacao.find(
        params[:id]
      )
    end

    def new
      carregar_dados_do_formulario
    end

    def create
      dados = movimentacao_params

      validar_origem_destino!(dados)

      Estoque::MovimentacaoService.new(
        user: current_user,
        params: dados
      ).call

      redirect_to estoque_movimentacoes_path,
        notice: "Movimentação registrada com sucesso."

    rescue ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound,
           ArgumentError => e

      carregar_dados_do_formulario

      flash.now[:alert] = e.message

      render :new,
        status: :unprocessable_entity
    end

    private

    # =========================================
    # VALIDAÇÃO DO FORMULÁRIO
    # =========================================

    def validar_origem_destino!(dados)
      tipo = dados[:tipo].to_s

      return unless %w[
        transferencia
        devolucao
      ].include?(tipo)

      origem_id = dados[:origem_local_id].presence
      destino_id = dados[:destino_local_id].presence

      if origem_id.blank?
        raise ArgumentError,
          "Selecione o estoque de origem."
      end

      if destino_id.blank?
        raise ArgumentError,
          "Selecione o estoque de destino."
      end

      if origem_id.to_s == destino_id.to_s
        raise ArgumentError,
          "Não é permitido transferir materiais para o próprio estoque. Selecione outro destino."
      end
    end

    # =========================================
    # DADOS DO FORMULÁRIO
    # =========================================

    def carregar_dados_do_formulario
      @produtos = Produto.ativos.order(:nome)
      @locais = Local.ativos.order(:nome)

      produto_id =
        params[:produto_id] ||
        params.dig(
          :estoque_movimentacao,
          :produto_id
        )

      origem_local_id =
        params[:origem_local_id] ||
        params.dig(
          :estoque_movimentacao,
          :origem_local_id
        )

      destino_local_id =
        params[:destino_local_id] ||
        params.dig(
          :estoque_movimentacao,
          :destino_local_id
        )

      if produto_id.present?
        @produto_selecionado =
          Produto.find_by(id: produto_id)
      end

      if origem_local_id.present?
        @origem_local_selecionado =
          Local.find_by(id: origem_local_id)
      end

      if destino_local_id.present?
        @destino_local_selecionado =
          Local.find_by(id: destino_local_id)
      end
    end

    # =========================================
    # PARÂMETROS PERMITIDOS
    # =========================================

    def movimentacao_params
      params.require(
        :estoque_movimentacao
      ).permit(
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
