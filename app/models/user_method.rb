class UserMethod < ApplicationRecord
  validates :user_id, :controller_method_id, presence: true
  
  belongs_to :controller_method
  belongs_to :user
end

