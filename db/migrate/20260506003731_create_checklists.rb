class CreateChecklists < ActiveRecord::Migration[8.0]
  def change
    create_table :checklists do |t|
      t.references :condominio, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :titulo
      t.datetime :data_visita
      t.integer :status

      t.timestamps
    end
  end
end
