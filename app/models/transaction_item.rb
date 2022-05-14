class TransactionItem < ApplicationRecord
  validates :quantity, :price, :transaction_id, presence: true
  belongs_to :trx, class_name: "Transaction", foreign_key: "transaction_id", optional: true
  
  belongs_to :item, optional: true
end
