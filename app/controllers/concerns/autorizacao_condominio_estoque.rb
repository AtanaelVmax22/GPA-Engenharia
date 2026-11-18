
module AutorizacaoCondominioEstoque
  extend ActiveSupport::Concern

  private

  def autorizado_no_condominio?(condominio)
    return false if current_user.blank?
    return false if condominio.blank?

    return true if current_user.admin?

    current_user.tecnico? &&
      CondominioTecnico.exists?(
        condominio_id: condominio.id,
        user_id: current_user.id
      )
  end

  def autorizar_condominio_estoque!(condominio)
    return true if autorizado_no_condominio?(condominio)

    head :forbidden
    false
  end
end
