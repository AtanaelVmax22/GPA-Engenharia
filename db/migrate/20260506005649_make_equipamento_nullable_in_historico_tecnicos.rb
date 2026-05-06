class MakeEquipamentoNullableInHistoricoTecnicos < ActiveRecord::Migration[8.0]
  def change
    change_column_null :historico_tecnicos, :equipamento_id, true
  end
end
