class HistoricoTecnicosController < ApplicationController
  before_action :set_condominio, only: [:index, :new, :create]
  before_action :set_historico, only: [:show, :edit, :update, :destroy]

  def index
    @historicos = @condominio.historico_tecnicos.includes(:user, :equipamento).recentes
    @historicos = @historicos.where(tipo: params[:tipo]) if params[:tipo].present?
    @pagy, @historicos = pagy(@historicos, limit: 15)
  end

  def show; end

  def new
    @historico = @condominio.historico_tecnicos.new(data_atendimento: Time.current)
    @historico.user = current_user
  end

  def create
    @condominio = Condominio.find(params[:condominio_id])
    @historico = @condominio.historico_tecnicos.new(historico_params)
    @historico.user = current_user
    if @historico.save
      redirect_to @historico, notice: "Registro técnico criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @condominio = @historico.condominio
  end

  def update
    if @historico.update(historico_params)
      redirect_to @historico, notice: "Registro atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    condominio = @historico.condominio
    @historico.destroy
    redirect_to condominio_path(condominio), notice: "Registro removido."
  end

  private

  def set_condominio
    @condominio = Condominio.find(params[:condominio_id])
  end

  def set_historico
    @historico = HistoricoTecnico.includes(:condominio, :equipamento, :user).find(params[:id])
  end

  def historico_params
    params.require(:historico_tecnico).permit(
      :equipamento_id, :tipo, :titulo, :descricao,
      :data_atendimento, :status, :pecas_utilizadas, fotos: []
    )
  end
end
