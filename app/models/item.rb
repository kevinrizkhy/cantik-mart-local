class Item < ApplicationRecord
  validates :item_cat_id, :name, :buy, :sell, :code, presence: true
  belongs_to :item_cat
  has_many :store_items
  has_many :retur_items
  has_many :order_items
  has_many :transaction_items
  has_many :grocer_items
end

