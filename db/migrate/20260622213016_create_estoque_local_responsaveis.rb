class CreateEstoqueLocalResponsaveis < ActiveRecord::Migration[8.0]
  def change
    create_table :estoque_local_responsaveis do |t|
      t.references :local, null: false, foreign_key: { to_table: :estoque_locais }
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :estoque_local_responsaveis,
      [:local_id, :user_id],
      unique: true,
      name: "index_estoque_local_responsaveis_unique"
  end
end