class Department< ApplicationRecord
  validates :name,  presence: true
  has_many :item_cat

  belongs_to :edited_by, class_name: "User", foreign_key: "edited_by", optional: true

end

