
class AddUniqueIndexesToEstoqueItens < ActiveRecord::Migration[8.0]
  def up
    add_index :estoque_itens, :codigo_patrimonio,
      unique: true,
      where: "codigo_patrimonio IS NOT NULL AND codigo_patrimonio <> ''",
      if_not_exists: true

    add_index :estoque_itens, :numero_serie,
      unique: true,
      where: "numero_serie IS NOT NULL AND numero_serie <> ''",
      if_not_exists: true

    add_index :estoque_itens, :mac,
      unique: true,
      where: "mac IS NOT NULL AND mac <> ''",
      if_not_exists: true
  end

  def down
    remove_index :estoque_itens,
      name: "index_estoque_itens_on_codigo_patrimonio",
      if_exists: true

    remove_index :estoque_itens,
      name: "index_estoque_itens_on_numero_serie",
      if_exists: true

    remove_index :estoque_itens,
      name: "index_estoque_itens_on_mac",
      if_exists: true
  end
end
