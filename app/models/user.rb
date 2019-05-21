class User < ApplicationRecord
  include Clearance::User
  validates :level, :email, presence: true
  validates_uniqueness_of :email

  enum level: { super_admin: 2,
                owner: 1,
                stock_admin: 3,
                cashier: 4,
                super_visi: 5
  }

  enum sex: {
    laki_laki: 0,
    perempuan: 1
  }

  belongs_to :store


  default_scope { order(created_at: :desc) }

  SUPER_ADMIN = 'super_admin'
  OWNER = 'owner'
  STOCK_ADMIN = 'stock_admin'
  CASHIER = "cashier"
  SUPER_VISI = 'super_visi'

  MALE = 'laki_laki'
  FEMALE = 'perempuan'

  has_many :transactions
  has_many :absents
end
