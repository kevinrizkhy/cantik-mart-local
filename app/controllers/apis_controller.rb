class ApisController < ApplicationController
  before_action :require_login


  def index
  	json_result = []
  	search = params[:search]
  	return render :json => json_result unless search.present?
  	if params[:api_type] == "item"
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
    elsif params[:api_type] == "trx"
      items = Item.where(code: search).pluck(:id)
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
    elsif params[:api_type] == "order"
      find_item = Item.find_by(code: search)
      return render :json => json_result unless find_item.present?
      item = []
      item << find_item.code
      item << find_item.name
      item << find_item.item_cat.name
      item << find_item.sell
      item << find_item.id
      json_result << item
    elsif params[:api_type] == "member"
      members = Member.where('lower(name) like ?', "%"+search.downcase+"%")
      members.each do|member|
        json_result << [member.card_number, member.name, member.address, member.phone]
      end
    end
    
  	render :json => json_result
  end

end