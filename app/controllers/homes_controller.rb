class HomesController < ApplicationController
  before_action :require_login
  require 'usagewatch'

  def index
    @last_backup = Backup.last
    gon.store_id = Transaction.last.store_id
    
    
    @absents = get_monthly_absent
    # SyncData.check_new_data_daily DateTime.now.beginning_of_day, DateTime.now.end_of_day
  end

  def get_monthly_absent
    absents = {}
    start_date = Date.today.beginning_of_month
    while start_date < Date.today.end_of_month
      absents[start_date] = [nil, nil]
      start_date = start_date + 1.day
    end
    start_date = DateTime.now.beginning_of_month
    end_date = start_date.end_of_month
    datas = Absent.where(user: current_user, check_in: start_date..end_date) 
    datas.each do |data|
      absents[data.check_in.to_date] = [data.check_in, data.check_out]
    end
    return absents
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

  def get_fingerprint
    Thread.start{
      SyncData.get_data
    }
    return redirect_success root_path, "Pengambilan data absensi sedang berjalan."
  end

  def delete_fingerprint
    Thread.start{
      2.times do 
        SyncData.get_data
      end
      SyncData.delete_data
    }
    return redirect_back_data_error root_path, "Data absensi telah dihapus"
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
