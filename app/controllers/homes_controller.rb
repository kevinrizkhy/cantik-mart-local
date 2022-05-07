class HomesController < ApplicationController
  before_action :require_login
  require 'usagewatch'

  def index
    # SyncData.sync_now

   #  @total_limit_items = StoreItem.where(store_id: current_user.store.id).where('stock < min_stock').count
   #  @total_orders = Order.where(store_id: current_user.store.id).where('date_receive is null').count
   #  @total_payments = Order.where(store_id: current_user.store.id).where('date_receive is not null and date_paid_off is null').count
   #  @total_returs = Retur.where(store_id: current_user.store.id).where('date_picked is not null').count
   #  UserMailer.welcome_email("kevin.rizkhy85@gmail.com", "Subject 1").deliver

  end

  def sync_daily
    sync_date = params[:sync_date]
    return redirect_back_data_error root_path, "Cek tanggal!" if sync_date.nil?
    sync_date = sync_date.to_datetime.localtime.beginning_of_day
    SyncData.sync_daily sync_date
    return redirect_success root_path, "SYNC ( " + sync_date.to_s + " ) telah dijalankan."
  
  end

  def update_store
    new_date = params[:new_date]
    return redirect_back_data_error root_path, "Cek tanggal!" if new_date.nil?
    new_date = new_date.to_datetime.localtime.beginning_of_day
    Store.all.update_all(last_post: new_date, last_update: new_date)
    return redirect_success root_path, "Last post dan update toko telah diubah"
  end

  def sync
    SyncData.sync_now
    return redirect_success root_path, "Sync selesai."
  end

  private

end
