class HomesController < ApplicationController
  before_action :require_login
  require 'usagewatch'

  def index
    gon.store_id = Transaction.last.store.id
  end

  def sync_daily
    sync_date = params[:sync_date]
    return redirect_back_data_error root_path, "Cek tanggal!" if sync_date.nil?
    sync_date = sync_date.to_datetime.localtime.beginning_of_day
    Thread.start{
      SyncData.sync_daily sync_date
    }
    return redirect_success root_path, "Sinkronisasi ( " + sync_date.to_date.to_s + " ) sedang berjalan."
  
  end

  def update_store
    new_date = params[:new_date]
    return redirect_back_data_error root_path, "Cek tanggal!" if new_date.nil?
    new_date = new_date.to_datetime.localtime.beginning_of_day
    Store.all.update_all(last_post: new_date, last_update: new_date)
    return redirect_success root_path, "Last post dan update toko telah diubah"
  end

  def sync
    Thread.start{
      SyncData.sync_daily DateTime.now
    }
    return redirect_success root_path, "Sync sedang berjalan."
  end

  private

end
