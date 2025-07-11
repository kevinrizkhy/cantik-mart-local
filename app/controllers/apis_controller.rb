class ApisController < ApplicationController
  before_action :require_login

  def index
    api_type = params[:api_type]
    if api_type == "item"
      get_item params
    elsif api_type == "order"
      get_item_order params
    elsif api_type == "trx"
      get_item_trx params
    elsif api_type == "member"
      get_member params
    elsif api_type == "voucher"
      get_voucher params
    elsif api_type == "get_notification"
      get_notification params
    elsif api_type == "update_notification"
      update_notification params
    elsif api_type == "total_trx"
      get_total_trx params
    end   
  end

  def get_total_trx params
    json_result = []
    search = params[:search].squish
    return render :json => json_result if search.empty?
    sync_date = search.to_datetime.localtime.beginning_of_day
    end_date = sync_date.end_of_day
    trxs = Transaction.where(created_at: sync_date..end_date)
    return render :json => json_result if trxs.empty?
    json_result << trxs.count
    json_result << trxs.sum(:grand_total).to_i
    render :json => json_result
  end

  def get_voucher params
    json_result = []
    search = params[:search].squish
    return render :json => json_result unless search.present?
    voucher = Voucher.find_by(voucher_code: search.to_i)
    if voucher.present?
      epoint = voucher.exchange_point
      json_result << [epoint.name, epoint.quantity]
    end
    render :json => json_result
  end

  def get_notification params
    json_result = []
    unread_notifications = Notification.where(to_user: current_user, read: 0).order("date_created DESC")
    notifications = Notification.where(to_user: current_user, read: 0).order("date_created DESC").limit(5)

    json_result << [DateTime.now, unread_notifications.count]
    notifications.each do|notification|
      json_result << [notification.from_user.name, notification.date_created, notification.message, notification.m_type, notification.link, notification.read]
    end
    render :json => json_result
  end

  def update_notification params
    json_result = []
    Notification.where(to_user: current_user, read: 0).order("date_created DESC").update_all(read: 1)
    notifications = Notification.where(to_user: current_user).order("date_created DESC").limit(5)

    json_result << [DateTime.now, 0]
    notifications.each do|notification|
      json_result << [notification.from_user.name, notification.date_created, notification.message, notification.m_type, notification.link, notification.read]
    end
    render :json => json_result
  end

  def get_member params
    json_result = []
    search = params[:search].squish
    return render :json => json_result unless search.present?
    search = search.gsub(/\s+/, "")
    if params[:only].present?
      members = Member.where(card_number: search)
    else
      members = Member.where('lower(name) like ? OR card_number = ?', "%"+search.downcase+"%", search)
    end
    members.each do|member|
      json_result << [member.card_number, member.name, member.address, member.phone, member.id]
    end
    render :json => json_result
  end

  def get_item params
    json_result = []
    search = params[:search].squish
    return render :json => json_result unless search.present?
    search = search.gsub(/\s+/, "")
    items = Item.where('lower(name) like ? OR code = ?', "%"+search.downcase+"%", search.downcase).pluck(:id)
    item_stores = StoreItem.where(store_id: current_user.store.id, item: items)
    return render :json => json_result unless item_stores.present?
    item_stores.each do |item_store|
      item = []
      item << item_id.code
      item << item_id.name
      item << item_id.item_cat.name
      item << item_id.sell
      item << item_store.stock
      json_result << item
    end
    render :json => json_result
  end

  def get_item_order params
    json_result = []
    search = params[:search].squish
    return render :json => json_result unless search.present?
    search = search.gsub(/\s+/, "")
    find_item = Item.find_by(code: search)
    return render :json => json_result unless find_item.present?
    item = []
    item << find_item.code
    item << find_item.name
    item << find_item.item_cat.name
    item << find_item.buy.round
    item << find_item.id
    item << find_item.sell
    json_result << item
    render :json => json_result
  end

  def get_item_trx params
    json_result = []
    qty = params[:qty]

    member = nil
    # if params[:member].present?
    #   member = Member.find_by(card_number: params[:member])
    # end

    search = params[:search].squish
    return render :json => json_result unless search.present?
    return render :json => json_result unless qty.present?
    return render :json => json_result if qty.to_f <= 0
    search = search.gsub(/\s+/, "")
    item_id = Item.search_by_code(search).take
    return render :json => json_result unless item_id.present?
    # item_store = StoreItem.find_by(store_id: current_user.store.id, item: item_id)
    # return render :json => json_result unless item_store.present?

    item = []
    item << item_id.code
    item << item_id.name.upcase
    item << item_id.item_cat.name.upcase
    
    curr_item = item_id
    qty = qty.to_i
    grocer_price = nil 
    grocer_price = curr_item.grocer_items.where("min <= ?", qty) if qty.to_i > 1
    if grocer_price.present?
      find_price = grocer_price.where('max >= ? AND min <= ?', qty, qty).order("max ASC")
      if find_price.present?
        price = find_price.first
        disc = find_price.first.discount
        disc = (disc * price.price) / 100 if disc <= 100
        if member.present?
          disc = find_price.first.discount
          disc = (disc * price.member_price) / 100 if disc <= 100
          item << price.member_price + disc
        else
          item << price.price + disc
        end
        item << disc
      else
        # LEBIH DARI JUMLAH HARGA GROSIR YANG DITENTUKAN
        find_price = grocer_price.where('max <= ? ', qty).order("max DESC")
        if find_price.present?
          price = find_price.first
          disc = find_price.first.discount
          disc = (disc * price.price) / 100 if disc <= 100
          if member.present?
            disc = find_price.first.discount
            disc = (disc * price.member_price) / 100 if disc <= 100
            item << price.member_price + disc
          else
            item << price.price + disc
          end
          item << disc
        else
          find_price = grocer_price.order("max ASC")
          price = find_price.first.price
          disc = find_price.first.discount
          disc = (disc * price) / 100 if disc <= 100
          item << price + disc
          item << disc
        end
      end
    else
      disc = item_id.discount
      disc = (disc * item_id.sell) / 100 if disc <= 100
      if member.present?
        disc = item_id.discount
        disc = (disc * item_id.sell_member) / 100 if disc <= 100
        item << item_id.sell_member + disc
      else
        item << item_id.sell + disc
      end
      item << disc
    end

    item << item_id.id


    promo = Promotion.where(buy_item: item_id).where("start_promo <= ? AND end_promo >= ? AND buy_quantity <= ?", DateTime.now, DateTime.now, qty).first
    if promo.present?
      hit_promo = qty.to_i / promo.buy_quantity
      item << promo.promo_code
      item << promo.free_item.code
      item << promo.free_item.name
      item << hit_promo * promo.free_quantity
    end
    
    json_result << item
    render :json => json_result
  end

end