class CondominiosController < ApplicationController
  before_action :set_condominio, only: [:show, :edit, :update, :destroy]

  def index
    @condominios = Condominio.order(:nome)
    @condominios = @condominios.where("nome ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    @condominios = @condominios.where(status: params[:status]) if params[:status].present?
    @pagy, @condominios = pagy(@condominios, limit: 12)
  end

  def show
    @equipamentos = @condominio.equipamentos.order(:categoria, :nome)
    @historicos = @condominio.historico_tecnicos.includes(:user).recentes.limit(10)
    @checklists = @condominio.checklists.includes(:user).order(created_at: :desc).limit(5)
  end

  def new
    @condominio = Condominio.new
  end

  def create
    @condominio = Condominio.new(condominio_params)
    if @condominio.save
      redirect_to @condominio, notice: "Condomínio cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @condominio.update(condominio_params)
      redirect_to @condominio, notice: "Condomínio atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @condominio.destroy
    redirect_to condominios_path, notice: "Condomínio removido."
  end

  private

  def set_condominio
    @condominio = Condominio.find(params[:id])
  end

  def condominio_params
    params.require(:condominio).permit(
      :nome, :endereco, :bairro, :cidade, :estado, :cep,
      :sindico_nome, :sindico_telefone, :sindico_email,
      :unidades, :status, :observacoes, fotos: []
    )
  end
end
