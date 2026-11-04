
class HistoricoTecnicosController < ApplicationController
  before_action :set_condominio,
    only: %i[index new create]

  before_action :set_historico,
    only: %i[show edit update destroy remover_foto]

  def index
    @historicos = @condominio.historico_tecnicos
      .includes(:user, :equipamento)
      .recentes

    if params[:tipo].present?
      @historicos = @historicos.where(
        tipo: params[:tipo]
      )
    end

    @pagy, @historicos = pagy(
      @historicos,
      limit: 15
    )
  end

  def show
  end

  def new
    @historico = @condominio.historico_tecnicos.new(
      data_atendimento: Time.current
    )

    @historico.user = current_user
  end

  def create
    @historico = @condominio.historico_tecnicos.new(
      historico_params
    )

    @historico.user = current_user

    if @historico.save
      redirect_to historico_tecnico_path(@historico),
        notice: "Registro técnico criado com sucesso."
    else
      render :new,
        status: :unprocessable_entity
    end
  end

  def edit
    @condominio = @historico.condominio
  end

  def update
    @condominio = @historico.condominio

    if @historico.update(historico_params)
      redirect_to historico_tecnico_path(@historico),
        notice: "Registro atualizado com sucesso."
    else
      render :edit,
        status: :unprocessable_entity
    end
  end

  def remover_foto
    foto = @historico.fotos_attachments.find(
      params[:foto_id]
    )

    # Remove somente a foto selecionada.
    # Não apaga o atendimento.
    foto.purge

    redirect_to historico_tecnico_path(@historico),
      notice: "Foto removida com sucesso.",
      status: :see_other
  end

  def destroy
    condominio = @historico.condominio

    if @historico.destroy
      redirect_to condominio_path(condominio),
        notice: "Registro removido.",
        status: :see_other
    else
      redirect_to historico_tecnico_path(@historico),
        alert: "Não foi possível remover o registro.",
        status: :see_other
    end
  end

  private

  def set_condominio
    @condominio = Condominio.find(
      params[:condominio_id]
    )
  end

  def set_historico
    @historico = HistoricoTecnico
      .includes(
        :condominio,
        :equipamento,
        :user,
        fotos_attachments: :blob
      )
      .find(params[:id])
  end

  def historico_params
    params.require(:historico_tecnico).permit(
      :equipamento_id,
      :tipo,
      :titulo,
      :descricao,
      :data_atendimento,
      :status,
      :pecas_utilizadas,
      fotos: []
    )
  end
end
