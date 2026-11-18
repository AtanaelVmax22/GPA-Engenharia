
module Estoque
  class InstalacoesController < BaseController
    include AutorizacaoCondominioEstoque

    before_action :carregar_condominio
    before_action :verificar_autorizacao
    before_action :carregar_itens, only: [:new, :create]

    def new
    end

    def create
      dados = params.require(:instalacao).permit(
        :item_id,
        :local_instalacao,
        :data_instalacao,
        :observacao
      )

      item = InstalacaoService.new(
        user: current_user,
        item_id: dados[:item_id],
        condominio: @condominio,
        local_instalacao: dados[:local_instalacao],
        data_instalacao: dados[:data_instalacao],
        observacao: dados[:observacao]
      ).call

      redirect_to condominio_path(@condominio),
        notice: "Equipamento #{item.identificacao} instalado com sucesso."

    rescue ArgumentError,
           ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e

      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end

    private

    def carregar_condominio
      @condominio = Condominio.find(params[:condominio_id])
    end

    def verificar_autorizacao
      autorizar_condominio_estoque!(@condominio)
    end

    def carregar_itens
      @itens = Item
        .includes(:produto)
        .where(
          local_id: @condominio.local_estoque&.id,
          condominio_id: @condominio.id,
          status: :em_estoque
        )
        .order(:codigo_patrimonio)
    end
  end
end
