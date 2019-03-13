class Supplier < ApplicationRecord
  validates :pic, :address, :phone, presence: true
  has_many :supplier_items
  has_many :returs
  enum supplier_type:{
    supplier: 0,
    warehouse: 1
  }
end
