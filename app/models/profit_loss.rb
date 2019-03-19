class ProfilLoss < ApplicationRecord
  validates :user_id, :store_id, :nominal, :date_created, :finance_type, presence: true
  
  enum finance_type: { 
    PROFIT:1,
    LOSS:2
  }

  belongs_to :store
  belongs_to :user

  PROFIT=1
  LOST=2
  
end
