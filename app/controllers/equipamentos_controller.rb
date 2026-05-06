class EquipamentosController < ApplicationController
  before_action :set_condominio, only: [:index, :new, :create]
  before_action :set_equipamento, only: [:show, :edit, :update, :destroy]

  def index
    @equipamentos = @condominio.equipamentos.order(:categoria, :nome)
  end

  def show
    @condominio = @equipamento.condominio
    @historicos = @equipamento.historico_tecnicos.includes(:user).recentes.limit(10)
  end

  def new
    @equipamento = @condominio.equipamentos.new
  end

  def create
    @equipamento = @condominio.equipamentos.new(equipamento_params)
    if @equipamento.save
      redirect_to equipamento_path(@equipamento), notice: "Equipamento cadastrado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @condominio = @equipamento.condominio
  end

  def update
    @condominio = @equipamento.condominio
    if @equipamento.update(equipamento_params)
      redirect_to equipamento_path(@equipamento), notice: "Equipamento atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    condominio = @equipamento.condominio
    @equipamento.destroy
    redirect_to condominio_path(condominio), notice: "Equipamento removido."
  end

  private

  def set_condominio
    @condominio = Condominio.find(params[:condominio_id])
  end

  def set_equipamento
    @equipamento = Equipamento.find(params[:id])
  end

  def equipamento_params
    params.require(:equipamento).permit(
      :nome, :categoria, :marca, :modelo, :numero_serie,
      :localizacao, :status, :data_instalacao, :observacoes, fotos: []
    )
  end
end
