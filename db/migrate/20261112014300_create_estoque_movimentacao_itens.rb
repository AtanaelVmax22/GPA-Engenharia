class CreateEstoqueMovimentacaoItens < ActiveRecord::Migration[8.0]
  def change
    create_table :estoque_movimentacao_itens do |t|
      t.references :movimentacao,
        null: false,
        foreign_key: {
          to_table: :estoque_movimentacoes
        },
        index: {
          name: "idx_estoque_mov_itens_movimentacao"
        }

      t.references :item,
        null: false,
        foreign_key: {
          to_table: :estoque_itens
        },
        index: {
          name: "idx_estoque_mov_itens_item"
        }

      t.timestamps
    end

    add_index :estoque_movimentacao_itens,
      [:movimentacao_id, :item_id],
      unique: true,
      name: "idx_estoque_mov_itens_unicos"
  end
end
