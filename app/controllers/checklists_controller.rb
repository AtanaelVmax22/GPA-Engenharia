class ChecklistsController < ApplicationController
  before_action :set_condominio, only: [:index, :new, :create]
  before_action :set_checklist, only: [:show, :update, :destroy]

  def index
    @checklists = @condominio.checklists.includes(:user).order(created_at: :desc)
  end

  def show; end

  def new
    @checklist = @condominio.checklists.new(data_visita: Time.current)
    @checklist.checklist_items.build(descricao: "Verificar portão veicular", ordem: 1)
    @checklist.checklist_items.build(descricao: "Verificar interfones", ordem: 2)
    @checklist.checklist_items.build(descricao: "Verificar câmeras", ordem: 3)
    @checklist.checklist_items.build(descricao: "Verificar controle de acesso", ordem: 4)
  end

  def create
    @checklist = @condominio.checklists.new(checklist_params)
    @checklist.user = current_user
    if @checklist.save
      redirect_to @checklist, notice: "Checklist criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @checklist.update(checklist_params)
    redirect_to @checklist
  end

  def destroy
    condominio = @checklist.condominio
    @checklist.destroy
    redirect_to condominio_path(condominio)
  end

  private

  def set_condominio
    @condominio = Condominio.find(params[:condominio_id])
  end

  def set_checklist
    @checklist = Checklist.includes(:condominio, :checklist_items).find(params[:id])
  end

  def checklist_params
    params.require(:checklist).permit(
      :titulo, :data_visita, :status,
      checklist_items_attributes: [:id, :descricao, :concluido, :ordem, :_destroy]
    )
  end
end
