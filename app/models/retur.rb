class Retur < ApplicationRecord
	max_paginates_per 10
  	validates :total_items, :store_id, presence: true
  	has_many :retur_items
  	belongs_to :store
  	belongs_to :supplier
end

