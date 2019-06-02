class HomesController < ApplicationController
  before_action :require_login
  require 'usagewatch'

  def index
    @total_limit_items = StoreItem.where(store_id: current_user.store.id).where('stock < min_stock').count
    @total_orders = Order.where(store_id: current_user.store.id).where('date_receive is null').count
    @total_payments = Order.where(store_id: current_user.store.id).where('date_receive is not null and date_paid_off is null').count
    @total_returs = Retur.where(store_id: current_user.store.id).where('date_picked is not null').count
  	# UserMailer.welcome_email("kevin.rizkhy85@gmail.com", "Subject 1").deliver
  	usw = Usagewatch
  end

  private

end
