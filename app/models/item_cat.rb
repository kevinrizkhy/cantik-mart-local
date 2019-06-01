class ItemCat< ApplicationRecord
  include PublicActivity::Model

  validates :name,  presence: true
  has_many :item
end

