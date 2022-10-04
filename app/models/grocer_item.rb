class GrocerItem< ApplicationRecord
  validates :min, :max, :price,  presence: true
  belongs_to :item

  belongs_to :edited_by, class_name: "User", foreign_key: "edited_by", optional: true

end

