class AddRefComplain < ActiveRecord::Migration[5.2]
  def change
  	remove_column :complains, :member_id
  	add_reference :complains, :user, foreign_key: true
  	add_reference :complains, :transaction, foreign_key: true
  	add_reference :complains, :member, foreign_key: true
  end
end
