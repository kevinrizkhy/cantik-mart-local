class CreateReturItems < ActiveRecord::Migration[5.2]
  def change
    create_table :retur_items do |t|
      t.references :item, foreign_key: true, null: false
      t.references :retur, foreign_key: true, null: false
      t.integer :quantity, null: false
      t.string :description, null: false
      t.integer :feedback, default: 0
      t.timestamps
    end
  end
end
