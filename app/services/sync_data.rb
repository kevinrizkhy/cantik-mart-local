class SyncData
	
  @@hostname = "http://www.cantikmart.com"
  # @@hostname = "http://localhost:3000"
  
	def initialize
	end


  # SyncData.deleteItem
  def self.deleteItem
    url = @@hostname+"/api/update_item_id"
    resp = Net::HTTP.get_response(URI.parse(url))
    return if resp.code.to_i != 200 
    datas = JSON.parse(resp.body)
    
    datas_ids = datas.values
    local_item_ids = Item.all.pluck(:id)
    diff_ids = local_item_ids-datas_ids

    not_found = []
    diff_ids.each do |diff_id|
      diff_item = Item.find_by(id: diff_id)
      next if diff_item.nil?
      if TransactionItem.where(item: diff_item).present?
        not_found << diff_id
        next
      end
      StoreItem.where(item_id: diff_id).destroy_all
      GrocerItem.where(item_id: diff_id).destroy_all
      Item.where(id: diff_id).destroy_all
    end
    puts "ID NOT FOUND : " + not_found.to_s
    puts "ID YANG TIDAK BISA DIHAPUS KARENA : "
    puts "1. LINK DENGAN TRX_ITEMS"
    puts "2. ITEM SUDAH DIHAPUS DARI SERVER PUSAT"
  end

  # SyncData.update_item_id
  def self.update_item_id
    url = @@hostname+"/api/update_item_id"
    resp = Net::HTTP.get_response(URI.parse(url))
    return if resp.code.to_i != 200 
    datas = JSON.parse(resp.body)
    
    datas_ids = datas.values
    local_item_ids = Item.all.pluck(:id)
    diff_ids = local_item_ids-datas_ids

    not_found = []
    diff_ids.each do |diff_id|
      diff_item = Item.find_by(id: diff_id)
      next if diff_item.nil?
      code = diff_item.code
      items = Item.where(code: code)

      if items.size == 1
        not_found << diff_id
        next
      end

      items_ids = items.pluck(:id)
      use_id = datas[code]
      remove_ids = items_ids - [use_id]
      TransactionItem.where(item_id: remove_ids).update_all(item_id: use_id)
      StoreItem.where(item_id: remove_ids).update_all(item_id: use_id)
      GrocerItem.where(item_id: remove_ids).update_all(item_id: use_id)
      Item.where(id: remove_ids).destroy_all
    end
    puts "ID yang tidak bisa dihapus : " + not_found.to_s
  end

  # SyncData.sync_daily DateTime.now.beginning_of_day-1.day
  def self.sync_daily sync_date
    puts "START: " + sync_date.to_s
    end_post = sync_date.end_of_day
    end_post = DateTime.now-5.minutes if sync_date.to_date == DateTime.now.to_date
    puts "END: " + end_post.to_s
    puts "-----------------------------"
    check_duplicate
    get_data 

    store = Transaction.last.store

    post_local_data_daily sync_date, end_post
    if sync_date.to_date == DateTime.now.to_date
      store.last_post = end_post 
      store.save!
    end
    puts "POST SUCCESS ! " + end_post.to_s
    puts "-----------------------------"

    check_new_data_daily sync_date, end_post
    if sync_date.to_date == DateTime.now.to_date
      store.last_update = end_post 
      store.save!
    end
    puts "UPDATE DATA SUCCESS ! " + end_post.to_s
    puts "-----------------------------"
  end


  # SyncData.sync_all_absents DateTime.now.beginning_of_day - 6.month
  def self.sync_all_absents sync_date
    url = @@hostname+"/api/post/trx"
    puts "START: " + sync_date.to_s
    end_post = DateTime.now
    puts "END: " + end_post.to_s
    puts "-----------------------------"
    get_data 

    string_data = "[]"
    encrypted_data = Base64.encode64(string_data)
    members_data = Member.where(updated_at: sync_date..end_post).to_json.to_s
    encrypted_data2 = Base64.encode64(members_data)
    absents_data = Absent.where(updated_at: sync_date..end_post).to_json.to_s
    encrypted_data3 = Base64.encode64(absents_data)
    puts "--> HEXING"
    b = []
    b << SecureRandom.hex(1)
    b << encrypted_data
    b << SecureRandom.hex(1)
    b << encrypted_data2
    b << SecureRandom.hex(1)
    b << encrypted_data3
    b << SecureRandom.hex(1)
    puts "--> POST"
    uri = URI(url)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {trxs: b}.to_json
    begin
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
        puts "--> POST DONE"
      end
      return true
    rescue
      puts "TIDAK ADA INTERNET"
      return false
    end
  end


  def self.get_data
    url = URI.parse('http://localhost/getData.php')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    return false if res.code == "404"
    
    return false if res.body.include? "Gagal"

    datas = JSON.parse(res.body)
    datas.each_with_index do |data, index|
      next if data==datas.first || data==datas.last
      fingerprint_id = data["pin"]
      user = User.find_by(fingerprint: fingerprint_id)
      next if user.nil?
      check_type = data["status"]
      date_time = data["waktu"]
      next if date_time.to_date != DateTime.now.to_date
      absent = Absent.find_by("DATE(check_in) = ? AND user_id = ?", DateTime.now.to_date, user.id)
      absent = Absent.create user: user, check_in: date_time, store: Transaction.last.store if absent.nil? && check_type == "0"
      if check_type == "0"
        next if absent.check_in.present?
        absent.check_in = date_time
        work_hours = calculate_work_hour absent.check_in, absent.check_out
        absent.work_hour = work_hours
      elsif check_type == "1"
        next if absent.check_out.present? || absent.check_in.nil?
        absent.check_out = date_time
        work_hours = calculate_work_hour absent.check_in, absent.check_out
        absent.work_hour = work_hours
      elsif check_type == "4"
        next if absent.overtime_in.present? || absent.check_out.nil?
        absent.overtime_in = date_time
        work_hours = calculate_work_hour absent.overtime_in, absent.overtime_out
        absent.overtime_hour = work_hours
      elsif check_type == "5"
        next if absent.overtime_out.present? || absent.overtime_in.nil?
        absent.overtime_out = date_time
        work_hours = calculate_work_hour absent.overtime_in, absent.overtime_out
        absent.overtime_hour = work_hours
      end
      absent.save!
    end
    return true
  end

  def self.calculate_work_hour check_in, check_out
    return nil if check_out.nil?
    divide_hour = check_out.to_time - check_in.to_time
    raw_hour = divide_hour / 1.hour
    hour = raw_hour.to_i.to_s
    divide_min = raw_hour - raw_hour.to_i
    raw_min = divide_min*60
    minute = raw_min.to_i.to_s
    sec = ((raw_min - raw_min.to_i)*60).to_i.to_s
    return hour+":"+minute+":"+sec
  end

  # last_post = DateTime.now.beginning_of_day
  # end_post = last_post.end_of_day
  # SyncData.post_local_data_daily last_post, end_post
  def self.post_local_data_daily last_post, end_post
    store = Transaction.last.store
    url = @@hostname+"/api/post/trx"

    post_trx_data = Transaction.where(updated_at: last_post..end_post)
    datas = []
    post_trx_data.each do |trx|
      temp_data = []
      temp_data << trx.to_json
      post_trx_items_data = TransactionItem.where(transaction_id: trx["id"]).to_json
      temp_data << post_trx_items_data
      datas << temp_data
    end

    string_data = datas.to_json.to_s
    encrypted_data = Base64.encode64(string_data)

    members_data = Member.where(updated_at: last_post..end_post).to_json.to_s
    encrypted_data2 = Base64.encode64(members_data)

    absents_data = Absent.where(updated_at: last_post..end_post).to_json.to_s
    # absents_data = []
    encrypted_data3 = Base64.encode64(absents_data)
    puts "----> TRX total : " + post_trx_data.count.to_s
    puts "--> HEXING"
    b = []
    b << SecureRandom.hex(1)
    b << encrypted_data
    b << SecureRandom.hex(1)
    b << encrypted_data2
    b << SecureRandom.hex(1)
    b << encrypted_data3
    b << SecureRandom.hex(1)
    puts "--> POST"
    uri = URI(url)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {trxs: b}.to_json
    begin
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
        store.last_post = end_post
        store.save!
        puts "--> POST DONE"
      end
      return true
    rescue
      puts "TIDAK ADA INTERNET"
      return false
    end
  end

  # SyncData.check_new_data_daily DateTime.now.beginning_of_day, DateTime.now.end_of_day
  def self.check_new_data_daily sync_date, end_post
    store = Transaction.last.store

    url = @@hostname+"/get/"+store.id.to_s+"?from="+sync_date.to_s+"&to="+end_post.to_s
    resp = Net::HTTP.get_response(URI.parse(url))
    return if resp.code.to_i != 200 
    GrocerItem.destroy_all
    data = JSON.parse(resp.body)
    data_keys = data.keys
    data_keys.each do |key|
      datas = data[key]
      datas.each do |new_data|
        sync_data(key, new_data)
      end
    end
    store.last_update = end_post
    store.save!
  end


  def self.sync_data key, data
    data["edited_by"] = nil
    begin
      if key == "users"
        user = User.find_by(id: data["id"].to_s)
        data.delete("edited_by")
        data.delete("encrypted_password")
        if user.present?
          data.delete("id")
          user.assign_attributes data
          user.save!
        else
          user = User.new data
          user.password = "cantikmart"
          user.save!
        end 
      elsif key=="members"
        member = Member.find_by(card_number: data["card_number"])
        data.delete("id")
        if member.present?
          member.assign_attributes data
          member.save! if member.changed?
        else
          Member.create data
        end
      elsif key=="exchange_points"
        epoint = ExchangePoint.find_by(id: data[:id])
        data.delete("id")
        if epoint.present?
          epoint.assign_attributes data
          epoint.save! if member.changed?
        else
          ExchangePoint.create data
        end
      elsif key=="vouchers"
        voucher = Voucher.find_by(id: data[:id])
        data.delete("id")
        if voucher.present?
          voucher.assign_attributes data
          voucher.save! if member.changed?
        else
          Voucher.create data
        end
      elsif key=="stores"
        store = Store.find_by(id: data["id"])
        if store.present?
          store.assign_attributes data
          store.save! if store.changed?
        else
          Store.create data
        end
      elsif key=="departments"
        department = Department.find_by(id: data["id"])
        if department.present?
          department.assign_attributes data
          department.save! if department.changed?
        else
          Department.create data
        end
      elsif key=="item_cats"
        item_cat = ItemCat.find_by(id: data["id"])
        if item_cat.present?
          item_cat.assign_attributes data
          item_cat.save! if item_cat.changed?
        else
          ItemCat.create data
        end
      elsif key=="items"
        item = Item.find_by(id: data["id"])
        if item.present?
          item.assign_attributes data
          item.save!
        else
          item = Item.create data
        end
      elsif key=="stocks"
        store_item = StoreItem.find_by(id: data["id"])
        if store_item.present?
          store_item.assign_attributes data
          store_item.save! if store_item.changed?
        else
          StoreItem.create data
        end
      elsif key=="promotions"
        promotion = Promotion.find_by(id: data["id"])
        if promotion.present?
          promotion.assign_attributes data
          promotion.save! if promotion.changed?
        else
          Promotion.create data
        end
      elsif key=="grocers"
          GrocerItem.create data
      end
    rescue =>e
      puts key
      puts "_________________________"
      puts data
    end
  end

  def self.check_duplicate 
      duplicate_trxs = Transaction.select(:invoice).group(:invoice).having("count(*) > 1").size
      duplicate_trxs.each do |trx_data|
        trx = Transaction.find_by(invoice: trx_data[0])
        store = trx.store
        if trx.transaction_items.present?
          trx.transaction_items.destroy_all
        end
        trx.destroy
      end
  end
end