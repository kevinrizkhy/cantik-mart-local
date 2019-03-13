class CreateStore < ActiveRecord::Migration[5.2]
  def change
    create_table :stores do |t|
      t.string :name, null: false, default: "DEFAULT STORE NAME"
      t.string :address, null: false, default: "DEFAULT STORE ADDRESS"
      t.bigint :phone, null: false, default: 1234567

      t.timestamps
    end
  end
end
