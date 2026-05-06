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
end
