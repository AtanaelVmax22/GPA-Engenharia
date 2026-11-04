module Estoque
  class ItensController < BaseController
    before_action :set_item, only: [:show, :edit, :update, :destroy]
    before_action :carregar_opcoes, only: [:new, :edit, :create, :update]
    before_action :require_admin!, except: [:index, :show]

    def index
      @status = params[:status].presence
      @busca = params[:busca].to_s.strip

      itens_scope = Item
        .includes(:produto, :local)
        .order(created_at: :desc)

      if @status.present? && Item.statuses.key?(@status)
        itens_scope = itens_scope.where(status: @status)
      end

      if @busca.present?
        itens_scope = itens_scope.joins(:produto).where(
          "estoque_produtos.nome ILIKE :busca OR estoque_itens.codigo_patrimonio ILIKE :busca OR estoque_itens.numero_serie ILIKE :busca OR estoque_itens.mac ILIKE :busca OR estoque_itens.fornecedor_nome ILIKE :busca OR estoque_itens.nota_fiscal_numero ILIKE :busca",
          busca: "%#{@busca}%"
        )
      end

      @itens_pagination = helpers.pagination_metadata(
        itens_scope,
        page: params[:page].presence || 1,
        per_page: 15
      )

      @itens = @itens_pagination[:records]
    end

    def show
    end

    def new
      @item = Item.new(
        status: :em_estoque,
        garantia_loja_dias: 90,
        garantia_fabrica_meses: 12
      )
    end

    def create
      @item = Item.new(item_params)

      if @item.save
        redirect_to estoque_item_path(@item), notice: "Item rastreável cadastrado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @item.update(item_params)
        redirect_to estoque_item_path(@item), notice: "Item rastreável atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @item.update!(status: :baixado)
      redirect_to estoque_itens_path, notice: "Item baixado com sucesso."
    end

    private

    def set_item
      @item = Item.find(params[:id])
    end

    def carregar_opcoes
      @produtos = Produto.order(:nome)
      @locais = Local.ativos.order(:nome)
    end

    def item_params
      params.require(:estoque_item).permit(
        :produto_id,
        :local_id,
        :condominio_id,
        :codigo_patrimonio,
        :numero_serie,
        :mac,
        :status,
        :data_compra,
        :data_instalacao,
        :fornecedor_nome,
        :nota_fiscal_numero,
        :garantia_loja_dias,
        :garantia_fabrica_meses,
        :observacao
      )
    end
  end
end