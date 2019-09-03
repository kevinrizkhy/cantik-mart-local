class Transaction < ApplicationRecord
  validates :invoice,:items, :total, :user_id, :grand_total, :payment_type,  presence: true
  has_many :transaction_items
  belongs_to :user
  belongs_to :member, optional: true
  belongs_to :complain, optional: true
end

