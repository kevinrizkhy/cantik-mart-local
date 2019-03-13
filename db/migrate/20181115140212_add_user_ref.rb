class AddUserRef < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :store, foreign_key: true
  end
end
