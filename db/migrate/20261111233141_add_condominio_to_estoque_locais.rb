
class AddCondominioToEstoqueLocais < ActiveRecord::Migration[8.0]
  def change
    add_reference :estoque_locais,
      :condominio,
      null: true,
      foreign_key: {
        to_table: :condominios
      },
      index: {
        unique: true,
        name: "idx_estoque_locais_condominio_unico"
      }
  end
end
