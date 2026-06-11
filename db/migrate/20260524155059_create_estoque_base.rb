class CreateEstoqueBase < ActiveRecord::Migration[8.0]
  def change
    create_table :estoque_produtos do |t|
      t.string :nome, null: false
      t.string :codigo
      t.string :categoria
      t.string :marca
      t.string :modelo
      t.string :unidade_medida, default: "unidade", null: false
      t.text :descricao

      t.decimal :valor_custo, precision: 12, scale: 2
      t.decimal :valor_venda, precision: 12, scale: 2
      t.decimal :estoque_minimo, precision: 12, scale: 3, default: 0, null: false

      t.boolean :ativo, default: true, null: false
      t.string :qr_token, null: false

      t.references :created_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end

    add_index :estoque_produtos, :codigo
    add_index :estoque_produtos, :qr_token, unique: true

    create_table :estoque_locais do |t|
      t.string :nome, null: false
      t.integer :tipo, default: 0, null: false

      t.string :cidade
      t.string :bairro
      t.string :endereco
      t.text :descricao

      t.references :responsavel, foreign_key: { to_table: :users }, null: true

      t.boolean :ativo, default: true, null: false
      t.string :qr_token, null: false

      t.timestamps
    end

    add_index :estoque_locais, :qr_token, unique: true

    create_table :estoque_saldos do |t|
      t.references :produto, null: false, foreign_key: { to_table: :estoque_produtos }
      t.references :local, null: false, foreign_key: { to_table: :estoque_locais }

      t.decimal :quantidade, precision: 12, scale: 3, default: 0, null: false

      t.timestamps
    end

    add_index :estoque_saldos, [:produto_id, :local_id], unique: true

    create_table :estoque_movimentacoes do |t|
      t.references :produto, null: false, foreign_key: { to_table: :estoque_produtos }

      t.references :origem_local, null: true, foreign_key: { to_table: :estoque_locais }
      t.references :destino_local, null: true, foreign_key: { to_table: :estoque_locais }

      t.references :user, null: false, foreign_key: true

      t.integer :tipo, null: false
      t.decimal :quantidade, precision: 12, scale: 3, null: false

      t.decimal :saldo_origem_antes, precision: 12, scale: 3
      t.decimal :saldo_origem_depois, precision: 12, scale: 3
      t.decimal :saldo_destino_antes, precision: 12, scale: 3
      t.decimal :saldo_destino_depois, precision: 12, scale: 3

      t.text :observacao
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    add_index :estoque_movimentacoes, :tipo
    add_index :estoque_movimentacoes, :created_at
  end
end