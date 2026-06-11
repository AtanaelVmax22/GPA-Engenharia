module Estoque
  class ProdutosController < BaseController
    before_action :set_produto, only: [:show, :edit, :update, :destroy, :qr]
    before_action :require_admin!, except: [:index, :show, :qr]

    def index
  produtos_scope = Produto.order(:nome)

    @produtos_pagination = helpers.pagination_metadata(
    produtos_scope,
    page: params[:page].presence || 1,
    per_page: 15
  )

    @produtos = @produtos_pagination[:records]
    end

    def show
      @saldos = @produto.saldos.includes(:local).order("estoque_locais.nome")
      @movimentacoes = @produto.movimentacoes.includes(:origem_local, :destino_local, :user).order(created_at: :desc).limit(20)
    end

    def new
      @produto = Produto.new(unidade_medida: "unidade", ativo: true)
    end

    def create
      @produto = Produto.new(produto_params)
      @produto.created_by = current_user

      if @produto.save
        redirect_to estoque_produto_path(@produto), notice: "Produto cadastrado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @produto.update(produto_params)
        redirect_to estoque_produto_path(@produto), notice: "Produto atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @produto.update!(ativo: false)
      redirect_to estoque_produtos_path, notice: "Produto inativado com sucesso."
    end

    def qr
    end

    private

    def set_produto
      @produto = Produto.find(params[:id])
    end

    def produto_params
      params.require(:estoque_produto).permit(
        :nome,
        :codigo,
        :categoria,
        :marca,
        :modelo,
        :unidade_medida,
        :descricao,
        :valor_custo,
        :valor_venda,
        :estoque_minimo,
        :ativo
      )
    end
  end
end