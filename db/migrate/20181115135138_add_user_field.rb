class AddUserField < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :phone, :bigint, null: false, default:8123456789
    add_column :users, :address, :string, null: false, default: 'DEFAULT ADDRESS'
    add_column :users, :id_card, :bigint, null: false, default: 123456789123456
    add_column :users, :sex, :integer, null: false, default: 0
  end
end
