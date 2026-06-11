class AddRecebimentoToEstoqueMovimentacoes < ActiveRecord::Migration[8.0]
  def up
    unless column_exists?(:estoque_movimentacoes, :status_recebimento)
      add_column :estoque_movimentacoes, :status_recebimento, :integer, default: 0, null: false
    end

    unless column_exists?(:estoque_movimentacoes, :recebido_por_id)
      add_reference :estoque_movimentacoes,
        :recebido_por,
        foreign_key: { to_table: :users },
        null: true
    end

    unless column_exists?(:estoque_movimentacoes, :recebido_em)
      add_column :estoque_movimentacoes, :recebido_em, :datetime
    end

    unless column_exists?(:estoque_movimentacoes, :observacao_recebimento)
      add_column :estoque_movimentacoes, :observacao_recebimento, :text
    end

    unless column_exists?(:estoque_movimentacoes, :qr_produto_confirmado_em)
      add_column :estoque_movimentacoes, :qr_produto_confirmado_em, :datetime
    end

    unless column_exists?(:estoque_movimentacoes, :qr_produto_confirmado_token)
      add_column :estoque_movimentacoes, :qr_produto_confirmado_token, :string
    end
  end

  def down
    remove_column :estoque_movimentacoes, :qr_produto_confirmado_token if column_exists?(:estoque_movimentacoes, :qr_produto_confirmado_token)
    remove_column :estoque_movimentacoes, :qr_produto_confirmado_em if column_exists?(:estoque_movimentacoes, :qr_produto_confirmado_em)
    remove_column :estoque_movimentacoes, :observacao_recebimento if column_exists?(:estoque_movimentacoes, :observacao_recebimento)
    remove_column :estoque_movimentacoes, :recebido_em if column_exists?(:estoque_movimentacoes, :recebido_em)

    if column_exists?(:estoque_movimentacoes, :recebido_por_id)
      remove_reference :estoque_movimentacoes,
        :recebido_por,
        foreign_key: { to_table: :users }
    end

    remove_column :estoque_movimentacoes, :status_recebimento if column_exists?(:estoque_movimentacoes, :status_recebimento)
  end
end