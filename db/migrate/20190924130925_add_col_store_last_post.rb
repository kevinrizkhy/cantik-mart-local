class AddColStoreLastPost < ActiveRecord::Migration[5.2]
  def change
  	add_column :stores,:last_post, :timestamp
  	add_column :stores, :last_update, :timestamp
  end
end
