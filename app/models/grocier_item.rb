class ItemCat< ApplicationRecord
  validates :min, :max, :price,  presence: true
  has_many :item
end

