class SyncData
	
	@@store_id = 1
  @@hostname = "http://www.cantikmart.com"
  # @@hostname = "http://localhost:3000"
  
	def initialize
	end

	def self.post_local_data
    store = Store.find_by(id: @@store_id)
    last_post = store.last_post
    if last_post == nil
      last_post = DateTime.now - 10.years
    end

    url = @@hostname+"/api/post/trx"
    new_post = DateTime.now


    post_trx_data = Transaction.where("updated_at > ? AND updated_at <= ?", last_post, new_post)
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
    encrypted_data3 = Base64.encode64(absents_data)

    b = []
    b << SecureRandom.hex(1)
    b << encrypted_data
    b << SecureRandom.hex(1)
    b << encrypted_data2
    b << SecureRandom.hex(1)
    b << encrypted_data3
    b << SecureRandom.hex(1)
    
    uri = URI(url)
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = {trxs: b}.to_json
    begin
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    rescue
      puts "TIDAK ADA INTERNET"
    end

    store.last_post = new_post
    store.save!
  end

  def self.check_new_data 
    store = Store.find_by(id: @@store_id)
    last_update = store.last_update
    if last_update == nil
      last_update = DateTime.now - 10.years
    end
    new_last_update = DateTime.now
    url = @@hostname+"/get/"+@@store_id.to_s+"?from="+last_update.to_s+"&to="+new_last_update.to_s
    resp = Net::HTTP.get_response(URI.parse(url))
    return if resp.code.to_i != 200 
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
      grocer_item = GrocerItem.find_by(id: data["id"])
      if grocer_item.present?
        grocer_item.assign_attributes data
        grocer_item.save! if grocer_item.changed?
      else
        GrocerItem.create data
      end
    end
  end
end