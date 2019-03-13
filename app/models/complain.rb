class Complain < ApplicationRecord
  validates :total_items, :member_id, :store_id, presence: true
  has_many :complain_items
  belongs_to :store
  belongs_to :member
end

