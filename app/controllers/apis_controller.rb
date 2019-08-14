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
    elsif api_type == "get_notification"
      get_notification params
    elsif api_type == "update_notification"
      update_notification params
    end  	
  end

  def get_notification params
    json_result = []
    last_check_string = params[:t]
    return render :json => json_result unless last_check_string.present?
    json_result << [DateTime.now]
    last_check = Time.zone.parse(last_check_string)
    notifications = Notification.where(to_user: current_user).where("date_created > ?", last_check).order("date_created DESC")
    notifications.each do|notification|
      json_result << [notification.from_user, notification.date_created, notification.message, notification.read]
    end
    render :json => json_result
  end

  def update_notification params
  end

  def get_member params
    json_result = []
    search = params[:search].squish
    return render :json => json_result unless search.present?
    search = search.gsub(/\s+/, "")
    members = Member.where('lower(name) like ?', "%"+search.downcase+"%")
    members.each do|member|
      json_result << [member.card_number, member.name, member.address, member.phone]
    end
    render :json => json_result
  end

  def get_item params
    json_result = []
    search = params[:search].squish
    return render :json => json_result unless search.present?
    search = search.gsub(/\s+/, "")
    items = Item.where('lower(name) like ?', "%"+search.downcase+"%").pluck(:id)
    item_stores = StoreItem.where(store_id: current_user.store.id, item_id: items)
    return render :json => json_result unless item_stores.present?
    item_stores.each do |item_store|
      item = []
      item << item_store.item.code
      item << item_store.item.name
      item << item_store.item_cat.name
      item << item_store.item.sell
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
    item << find_item.sell
    item << find_item.id
    json_result << item
    render :json => json_result
  end

  def get_item_trx params
    json_result = []
    qty = params[:qty]
    search = params[:search].squish
    return render :json => json_result unless search.present?
    return render :json => json_result unless qty.present?
    search = search.gsub(/\s+/, "")
    items = Item.where(code: search).pluck(:id)
    item_stores = StoreItem.where(store_id: current_user.store.id, item_id: items)
    return render :json => json_result unless item_stores.present?
    item_stores.each do |item_store|
      item = []
      item << item_store.item.code
      item << item_store.item.name
      item << item_store.item.item_cat.name
      curr_item = item_store.item
      grocer_price = curr_item.grocer_items
      if grocer_price.present?
        find_price = grocer_price.where('max >= ? AND min <= ?', qty, qty).order("max ASC")
        if find_price.present?
          item << find_price.first.price
        else
          item << item_store.item.sell
        end
      else
        item << item_store.item.sell
      end
      json_result << item
    end
    render :json => json_result
  end

end