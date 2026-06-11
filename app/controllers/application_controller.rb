class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!

  include Pagy::Backend

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  protected

  def require_admin!
    redirect_to dashboard_path, alert: "Acesso restrito a administradores." unless current_user&.admin?
  end

    private

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
   def require_admin!
    return if current_user&.admin?

    redirect_to dashboard_path, alert: "Acesso negado. Apenas administradores podem realizar esta ação."
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end