class CreateTableItemCat < ActiveRecord::Migration[5.2]
  def change
    create_table :item_cats do |t|
      t.string :name, null: false, default: 'DEFAULT'
    end
  end
end
