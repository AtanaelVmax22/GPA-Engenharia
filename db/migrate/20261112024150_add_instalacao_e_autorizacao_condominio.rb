
class AddInstalacaoEAutorizacaoCondominio < ActiveRecord::Migration[8.0]
  def change
    add_column :estoque_itens,
      :local_instalacao,
      :string

    add_reference :estoque_itens,
      :instalado_por,
      null: true,
      foreign_key: { to_table: :users },
      index: true

    create_table :condominio_tecnicos do |t|
      t.references :condominio,
        null: false,
        foreign_key: true

      t.references :user,
        null: false,
        foreign_key: true

      t.timestamps
    end

    add_index :condominio_tecnicos,
      [:condominio_id, :user_id],
      unique: true,
      name: "idx_condominio_tecnicos_unicos"
  end
end
