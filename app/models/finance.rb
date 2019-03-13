class Finance < ApplicationRecord
  validates :user_id, :store_id, :nominal, :finance_type, :date_created, presence: true
  
  enum finance_type: { 
    Asset: 1,
    Debt: 2,
    Receivables: 3,
    Operational: 4,
    Fix_cost: 5,
    Tax: 6,
    Transactions: 7
  }

  belongs_to :store
  belongs_to :user

  ASSET=1
  DEBT=2
  RECEIVABLES=3
  OPERATIONAL=4
  FIX_COST=5
  TAX=6
  TRANSACTIONS = 7
  
  belongs_to :order, optional: true
end
