class ControllerMethod < ApplicationRecord
  validates :name, presence: true
  
  belongs_to :controller
end

