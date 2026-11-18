
module Estoque
  class EntradasAvulsasController < BaseController
    include AutorizacaoCondominioEstoque

    before_action :carregar_opcoes, only: [:new, :create]

    def new
      @dados = {}

      return if params[:condominio_id].blank?

      condominio = Condominio.find(params[:condominio_id])

      return unless autorizar_condominio_estoque!(condominio)

      @local_fixo = condominio.local_estoque

      unless @local_fixo&.ativo?
        redirect_to condominio_path(condominio),
          alert: "Este condomínio não possui estoque ativo."
        return
      end

      @dados["local_id"] = @local_fixo.id.to_s
    end

    def create
      @dados = entrada_params.to_h

      local = Local.find(entrada_params[:local_id])

      unless local.condominio? && local.condominio.present?
        raise ArgumentError,
          "Selecione um condomínio válido."
      end

      return unless autorizar_condominio_estoque!(
        local.condominio
      )

      @item = EntradaAvulsaService.new(
        user: current_user,
        params: entrada_params
      ).call

      redirect_to condominio_path(local.condominio),
        notice: "Equipamento #{@item.codigo_patrimonio} registrado com sucesso."

    rescue ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound,
           ActiveRecord::RecordNotUnique,
           ArgumentError => e

      flash.now[:alert] =
        if e.is_a?(ActiveRecord::RecordNotUnique)
          "Já existe um equipamento com esse identificador."
        else
          e.message
        end

      render :new, status: :unprocessable_entity
    end

    private

    def carregar_opcoes
      @produtos = Produto.ativos.order(:nome)

      @locais =
        if current_user.admin?
          Local.ativos
            .where(tipo: :condominio)
            .includes(:condominio)
            .order(:nome)
        else
          Local.ativos
            .where(
              tipo: :condominio,
              condominio_id: CondominioTecnico
                .where(user_id: current_user.id)
                .select(:condominio_id)
            )
            .includes(:condominio)
            .order(:nome)
        end
    end

    def entrada_params
      params.require(:entrada_avulsa).permit(
        :produto_id,
        :local_id,
        :codigo_patrimonio,
        :numero_serie,
        :mac,
        :data_compra,
        :fornecedor_nome,
        :nota_fiscal_numero,
        :garantia_loja_dias,
        :garantia_fabrica_meses,
        :observacao
      )
    end
  end
end
