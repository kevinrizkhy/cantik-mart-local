class CreateMember < ActiveRecord::Migration[5.2]
  def change
    create_table :members do |t|
      t.string :name, null: false
      t.string :id_card
      t.string :card_number, null: false
      t.bigint :phone, null: false
      t.integer :sex
      t.string :address

      t.timestamps
    end
  end
end
