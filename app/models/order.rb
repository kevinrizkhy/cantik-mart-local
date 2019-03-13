class Order < ApplicationRecord
  validates :invoice,:total_items, :total, :store_id, presence: true
  has_many :order_items
  has_many :order_inv
  belongs_to :store
  belongs_to :supplier
end

