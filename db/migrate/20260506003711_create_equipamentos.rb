class CreateEquipamentos < ActiveRecord::Migration[8.0]
  def change
    create_table :equipamentos do |t|
      t.references :condominio, null: false, foreign_key: true
      t.string :nome
      t.string :categoria
      t.string :marca
      t.string :modelo
      t.string :numero_serie
      t.string :localizacao
      t.integer :status
      t.date :data_instalacao
      t.text :observacoes

      t.timestamps
    end
  end
end
