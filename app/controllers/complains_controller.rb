class ComplainsController < ApplicationController
  before_action :require_login
  def index
    @complains = Complain.page param_page
    if params[:search].present?
      search = params[:search].downcase
      @search = search
      search_arr = search.split(":")
      if search_arr.size > 2
        complainn redirect_back_no_access_right
      elsif search_arr.size == 2
        store = Store.where('lower(name) like ?', "%"+search_arr[1].downcase+"%").pluck(:id)
        member = Member.where('lower(pic) like ?', "%"+search_arr[1].downcase+"%").pluck(:id)
          if search_arr[0]== "to" && member.present?
            @complains = @complains.where(member: member)
          elsif search_arr[0]== "from" && store.present?
            @complains = @complains.where(store_id: store)
          else
            @complains = @complains.where("invoice like ?", "%"+ search_arr[1]+"%")
          end
      else
        @complains = @complains.where("invoice like ?", "%"+ search+"%")
      end
    end
  end

  def new
    @members = Member.all
    @inventories = StoreItem.page param_page
    all_options = ""
    @inventories.each do |inventory|
      stock = inventory.item
      all_options+= "<option value="+stock.id.to_s+" data-subtext='"+stock.item_cat.name+"'>"+stock.name+"</option>"
    end
    gon.select_options = all_options
    gon.inv_count = 2
  end

  def create
    invoice = "CMP-" + Time.now.to_i.to_s
    items = complain_items
    total_item = items.size
    address_to = params[:complain][:member_id]

    complain = Complain.create invoice: invoice,
      total_items: total_item,
      store_id: current_user.store.id,
      date_created: Time.now,
      member_id: address_to

    complain_items.each do |complain_item|
      item = Item.find complain_item[0]
      break if item.nil?
      ComplainItem.create item_id: complain_item[0], complain_id: complain.id, quantity: complain_item[1], description: complain_item[2]
      store_stock = StoreItem.find_by(item_id: item.id)
      store_stock.stock = store_stock.stock + complain_item[1].to_i
      store_stock.save!
    end
    return redirect_to complains_path
  end

  private
    def complain_items
      items = []
      params[:complain][:complain_items].each do |item|
        items << item[1].values
      end
      items
    end

    def decrease_stock complain_id
      complain_items = complainItem.where(complain_id: complain_id)
      complain_items.each do |complain_item|
        confirmation = complain_item.accept_item
        item = StoreItem.find_by(item_id: complain_item.item.id, store_id: current_user.store.id)
        new_stock = item.stock.to_i - confirmation.to_i
        item.stock = new_stock
        item.save!
      end
    end

    def param_page
      params[:page]
    end

end
