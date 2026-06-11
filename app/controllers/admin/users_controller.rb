class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.order(:nome, :email)
  end

  def show
  end

  def new
    @user = User.new(role: :tecnico)
  end

  def create
    @user = User.new(user_create_params)

    if @user.save
      redirect_to admin_users_path, notice: "Usuário criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    params_to_update = user_update_params

    if params_to_update[:password].blank?
      params_to_update.delete(:password)
      params_to_update.delete(:password_confirmation)
    end

    if @user.update(params_to_update)
      redirect_to admin_users_path, notice: "Usuário atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "Você não pode excluir o próprio usuário logado."
      return
    end

    if @user.admin? && User.admin.count <= 1
      redirect_to admin_users_path, alert: "Não é possível excluir o último administrador do sistema."
      return
    end

    @user.destroy
    redirect_to admin_users_path, notice: "Usuário removido com sucesso."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_admin!
    return if current_user&.admin?

    redirect_to dashboard_path, alert: "Acesso negado. Apenas administradores podem gerenciar usuários."
  end

  def user_create_params
    params.require(:user).permit(
      :nome,
      :email,
      :telefone,
      :role,
      :password,
      :password_confirmation
    )
  end

  def user_update_params
    params.require(:user).permit(
      :nome,
      :email,
      :telefone,
      :role,
      :password,
      :password_confirmation
    )
  end
end