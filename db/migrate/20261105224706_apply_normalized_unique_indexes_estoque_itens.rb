
class ApplyNormalizedUniqueIndexesEstoqueItens < ActiveRecord::Migration[8.0]
  def up
    remove_index :estoque_itens,
      name: "index_estoque_itens_on_codigo_patrimonio",
      if_exists: true

    remove_index :estoque_itens,
      name: "index_estoque_itens_on_numero_serie",
      if_exists: true

    remove_index :estoque_itens,
      name: "index_estoque_itens_on_mac",
      if_exists: true

    add_index :estoque_itens,
      "UPPER(BTRIM(codigo_patrimonio))",
      unique: true,
      name: "idx_estoque_itens_patrimonio_normalizado",
      where: "codigo_patrimonio IS NOT NULL AND BTRIM(codigo_patrimonio) <> ''",
      if_not_exists: true

    add_index :estoque_itens,
      "UPPER(BTRIM(numero_serie))",
      unique: true,
      name: "idx_estoque_itens_serie_normalizada",
      where: "numero_serie IS NOT NULL AND BTRIM(numero_serie) <> ''",
      if_not_exists: true

    add_index :estoque_itens,
      "UPPER(REGEXP_REPLACE(mac, '[^0-9A-Fa-f]', '', 'g'))",
      unique: true,
      name: "idx_estoque_itens_mac_normalizado",
      where: "mac IS NOT NULL AND BTRIM(mac) <> ''",
      if_not_exists: true
  end

  def down
    remove_index :estoque_itens,
      name: "idx_estoque_itens_patrimonio_normalizado",
      if_exists: true

    remove_index :estoque_itens,
      name: "idx_estoque_itens_serie_normalizada",
      if_exists: true

    remove_index :estoque_itens,
      name: "idx_estoque_itens_mac_normalizado",
      if_exists: true

    add_index :estoque_itens,
      :codigo_patrimonio,
      unique: true,
      where: "codigo_patrimonio IS NOT NULL AND codigo_patrimonio <> ''",
      if_not_exists: true

    add_index :estoque_itens,
      :numero_serie,
      unique: true,
      where: "numero_serie IS NOT NULL AND numero_serie <> ''",
      if_not_exists: true

    add_index :estoque_itens,
      :mac,
      unique: true,
      where: "mac IS NOT NULL AND mac <> ''",
      if_not_exists: true
  end
end
