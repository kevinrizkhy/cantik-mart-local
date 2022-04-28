class SyncData
	
  @@hostname = "http://www.cantikmart.com"
  # @@hostname = "http://localhost:3000"
  
	def initialize
    sync_now
	end

  def self.sync_now
    puts "START: " + DateTime.now.to_s
    puts "-----------------------------"
    curr_date = DateTime.now - 10.minutes
    check_duplicate
    get_data 

    store = Transaction.last.store

    post_local_data curr_date
    store.last_post = new_post
    store.save!

    check_new_data curr_date
    store.last_post = new_post
    store.save!
    puts "-----------------------------"
    puts "END: " + DateTime.now.to_s
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
      absent = Absent.create user: user, check_in: date_time if absent.nil? && check_type == "0"
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

	def self.post_local_data new_post
    store = Transaction.last.store
    last_post = store.last_post
    if last_post == nil
      last_post = DateTime.now - 10.years
    end

    url = @@hostname+"/api/post/trx"


    post_trx_data = Transaction.where(updated_at: last_post..new_post)
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

    members_data = Member.where("updated_at > ? AND updated_at <= ?", last_post, new_post).to_json.to_s
    encrypted_data2 = Base64.encode64(members_data)

    absents_data = Absent.where("updated_at > ? AND updated_at <= ?", last_post, new_post).to_json.to_s
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
        store.last_post = new_post
        store.save!
        puts "--> POST DONE"
      end
      return true
    rescue
      puts "TIDAK ADA INTERNET"
      return false
    end

    
  end

  def self.check_new_data new_last_update
    store = Transaction.last.store
    last_update = store.last_update
    if last_update == nil
      last_update = DateTime.now - 10.years
    end
    url = @@hostname+"/get/"+store.id.to_s+"?from="+last_update.to_s+"&to="+new_last_update.to_s
    resp = Net::HTTP.get_response(URI.parse(url))
    return if resp.code.to_i != 200 
    GrocerItem.destroy_all
    data = JSON.parse(resp.body)
    data_keys = data.keys
    data_keys.each do |key|
      datas = data[key]
      datas.each do |new_data|
        sync_data key, new_data
      end
    end
    store.last_update = new_last_update
    store.save!
  end

  def self.sync_data key, data
    begin
      if key == "users"
        user = User.find_by(id: data["id"])
        data["password"] = "admin123"
        if user.present?
          user.assign_attributes data
          user.save! if user.changed?
        else
          User.create data
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
          Item.create data
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
    rescue Exception
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