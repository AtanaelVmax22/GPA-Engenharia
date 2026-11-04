class CreateEstoqueItens < ActiveRecord::Migration[8.0]
  def change
    create_table :estoque_itens do |t|
      t.references :produto, null: false, foreign_key: { to_table: :estoque_produtos }
      t.references :local, null: true, foreign_key: { to_table: :estoque_locais }

      t.bigint :condominio_id

      t.string :codigo_patrimonio
      t.string :numero_serie
      t.string :mac

      t.integer :status, null: false, default: 0

      t.date :data_compra
      t.date :data_instalacao

      t.string :fornecedor_nome
      t.string :nota_fiscal_numero

      t.integer :garantia_loja_dias, null: false, default: 90
      t.integer :garantia_fabrica_meses, null: false, default: 12

      t.text :observacao

      t.timestamps
    end

    add_index :estoque_itens, :condominio_id
    add_index :estoque_itens, :codigo_patrimonio
    add_index :estoque_itens, :numero_serie
    add_index :estoque_itens, :mac
    add_index :estoque_itens, :status
  end
end