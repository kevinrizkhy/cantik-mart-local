class Transfer < ApplicationRecord
  validates :invoice, :from_store, :to_store,:date_created, presence: true
  belongs_to :from_store, class_name: "Store", foreign_key: "from_store_id", optional: true
  belongs_to :to_store, class_name: "Store", foreign_key: "to_store_id", optional: true
  has_many :transfer_items
end

