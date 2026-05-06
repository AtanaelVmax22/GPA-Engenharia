class MakeCondominioNullableInPostTecnicos < ActiveRecord::Migration[8.0]
  def change
    change_column_null :post_tecnicos, :condominio_id, true
  end
end
