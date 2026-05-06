class CreateHistoricoTecnicos < ActiveRecord::Migration[8.0]
  def change
    create_table :historico_tecnicos do |t|
      t.references :condominio, null: false, foreign_key: true
      t.references :equipamento, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :tipo
      t.string :titulo
      t.text :descricao
      t.datetime :data_atendimento
      t.integer :status
      t.text :pecas_utilizadas

      t.timestamps
    end
  end
end
