class CreateCondominios < ActiveRecord::Migration[8.0]
  def change
    create_table :condominios do |t|
      t.string :nome
      t.string :endereco
      t.string :bairro
      t.string :cidade
      t.string :estado
      t.string :cep
      t.string :sindico_nome
      t.string :sindico_telefone
      t.string :sindico_email
      t.integer :unidades
      t.integer :status
      t.text :observacoes

      t.timestamps
    end
  end
end
