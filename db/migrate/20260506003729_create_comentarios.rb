class CreateComentarios < ActiveRecord::Migration[8.0]
  def change
    create_table :comentarios do |t|
      t.references :post_tecnico, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :conteudo

      t.timestamps
    end
  end
end
