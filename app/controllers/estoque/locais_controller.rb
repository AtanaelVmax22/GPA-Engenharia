module Estoque
  class LocaisController < BaseController
    before_action :set_local, only: [:show, :edit, :update, :destroy, :qr]
    before_action :require_admin!, except: [:index, :show, :qr]

    def index
      @locais = Local.ativos.order(:nome)
    end

   def show
  saldos_scope = @local.saldos.includes(:produto).order("estoque_produtos.nome")

  @saldos_pagination = helpers.pagination_metadata(
    saldos_scope,
    page: params[:page].presence || 1,
    per_page: 15
  )

  @saldos = @saldos_pagination[:records]

  @movimentacoes = Movimentacao
    .includes(:produto, :origem_local, :destino_local, :user)
    .where("origem_local_id = :id OR destino_local_id = :id", id: @local.id)
    .order(created_at: :desc)
    .limit(20)
   end


    def new
      @local = Local.new(tipo: :central, ativo: true)
    end

    def create
      @local = Local.new(local_params)

      if @local.save
        redirect_to estoque_local_path(@local), notice: "Estoque cadastrado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @local.update(local_params)
        redirect_to estoque_local_path(@local), notice: "Estoque atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @local.update!(ativo: false)
      redirect_to estoque_locais_path, notice: "Estoque inativado com sucesso."
    end

    def qr
    end

    private

    def set_local
      @local = Local.find(params[:id])
    end

    def local_params
      params.require(:estoque_local).permit(
        :nome,
        :tipo,
        :cidade,
        :bairro,
        :endereco,
        :descricao,
        :responsavel_id,
        :ativo
      )
    end
  end
end