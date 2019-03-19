class CashFlow < ApplicationRecord
  validates :user_id, :store_id, :nominal, :finance_type, :date_created, presence: true
  
  enum finance_type: { 
    Asset: 1,
    Debt: 2,
    Credit: 3,
    Operational: 4,
    Fix_cost: 5,
    Tax: 6,
    Transactions: 7,
    HPP: 8,
    Profit: 9,
    Outcome: 10,
    Income: 11,
    Cash: 12,
    Stock_Value: 13
  }

  belongs_to :store
  belongs_to :user

  ASSET=1
  DEBT=2
  CREDIT=3
  OPERATIONAL=4
  FIX_COST=5
  TAX=6
  TRANSACTIONS = 7
  HPP = 8
  PROFIT = 9
  OUTCOME = 10
  INCOME = 11
  CASH = 12
  STOCK_VALUE = 13
end