class CreateChecklistItems < ActiveRecord::Migration[8.0]
  def change
    create_table :checklist_items do |t|
      t.references :checklist, null: false, foreign_key: true
      t.string :descricao
      t.boolean :concluido
      t.integer :ordem

      t.timestamps
    end
  end
end
