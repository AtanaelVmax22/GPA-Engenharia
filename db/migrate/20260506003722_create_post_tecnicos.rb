class CreatePostTecnicos < ActiveRecord::Migration[8.0]
  def change
    create_table :post_tecnicos do |t|
      t.references :user, null: false, foreign_key: true
      t.references :condominio, null: false, foreign_key: true
      t.string :titulo
      t.text :conteudo
      t.boolean :publico

      t.timestamps
    end
  end
end
