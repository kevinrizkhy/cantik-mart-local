class StoreLastUpdate < ActiveRecord::Migration[5.2]
  def change
  	add_column :stores, :last_update, :timestamp
  	add_column :stores, :last_post, :timestamp
  end
end
