class CreateCurtidas < ActiveRecord::Migration[8.0]
  def change
    create_table :curtidas do |t|
      t.references :post_tecnico, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
