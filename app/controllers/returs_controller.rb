class RetursController < ApplicationController
  before_action :require_login
  def index
    @returs = Retur.page param_page
    if params[:search].present?
      search = params[:search].downcase
      @search = search
      search_arr = search.split(":")
      if search_arr.size > 2
        return redirect_back_no_access_right
      elsif search_arr.size == 2
        store = Store.where('lower(name) like ?', "%"+search_arr[1].downcase+"%").pluck(:id)
        supplier = Supplier.where('lower(pic) like ?', "%"+search_arr[1].downcase+"%").pluck(:id)
          if search_arr[0]== "to" && supplier.present?
            @returs = @returs.where(supplier_id: supplier)
          elsif search_arr[0]== "from" && store.present?
            @returs = @returs.where(store_id: store)
          else
            @returs = @returs.where("invoice like ?", "%"+ search_arr[1]+"%")
          end
      else
        @returs = @returs.where("invoice like ?", "%"+ search+"%")
      end
    end
  end

  def new
    @suppliers = Supplier.select(:id, :pic, :address).order("supplier_type DESC").all
    if params[:item_id].present?
      @supplier_items = SupplierItem.where(item_id: params[:item_id])
      if @supplier_items.count > 1
        return redirect_to item_suppliers_path(id: params[:item_id])
      end
    end
    if params[:supplier_id].present?
      @supplier_id = params[:supplier_id].to_i
    else
      @supplier_id = @suppliers.first.id.to_i
    end

    @supplier_items = SupplierItem.where(supplier_id: @supplier_id)
    all_options = ""
    @supplier_items.each do |supplier_item|
      s_item = supplier_item.item
      all_options+= "<option value="+s_item.id.to_s+" data-subtext='"+s_item.item_cat.name+"'>"+s_item.name+"</option>"
    end
    gon.select_options = all_options

    ongoing_order_ids = Order.where('date_receive is null and date_paid_off is null').pluck(:id)
    @ongoing_order_items = OrderItem.where(order_id: ongoing_order_ids)

    @inventories = StoreItem.page param_page
    store_id = current_user.store.id
    @inventories = @inventories.where(store_id: store_id).where('stock < min_stock')

    gon.inv_count = @inventories.count + 2
  end

  def create
    invoice = "RE-" + Time.now.to_i.to_s
    items = retur_items
    total_item = items.size
    address_to = params[:retur][:supplier_id]

    retur = Retur.create invoice: invoice,
      total_items: total_item,
      store_id: current_user.store.id,
      date_created: Time.now,
      supplier_id: address_to

    items.each do |retur_item|
      item = Item.find retur_item[0]
      if item.nil?
        ReturItem.where(retur: retur).delete_all
        Retur.where(retur: retur).delete
      end
      a = ReturItem.create item_id: retur_item[0], retur_id: retur.id, quantity: retur_item[1], description: retur_item[2]
    end
    return redirect_to returs_path
  end

  def confirmation
    return redirect_back_no_access_right unless params[:id].present?
    @retur = Retur.find params[:id]
    return redirect_to returs_path if @retur.nil?
    return redirect_back_no_access_right if @retur.date_picked.present? || @retur.date_approve.present?
    @retur_items = ReturItem.where(retur_id: @retur.id)
  end

  def accept
    return redirect_back_no_access_right unless params[:id].present?
    retur = Retur.find params[:id]
    return redirect_back_no_access_right if retur.nil?
    return redirect_back_no_access_right if retur.date_picked.present? || retur.date_approve.present?
    items = retur_items
    items.each do |item|
      retur_item = ReturItem.find item[0]
      break if retur_item.nil?
      break if retur_item.quantity < item[1].to_i
      retur_item.accept_item = item[1]
      retur_item.save!
    end
    retur.date_approve = Time.now
    retur.save!
    return redirect_to retur_items_path(id: params[:id])
  end

  def picked
    return redirect_back_no_access_right unless params[:id].present?
    retur = Retur.find params[:id]
    return redirect_back_no_access_right if retur.nil?
    return redirect_back_no_access_right unless retur.date_picked.present? || retur.date_approve.present?
    retur.date_picked = Time.now
    retur.save!
    decrease_stock params[:id]
    return redirect_to returs_path
  end

  def destroy
    return redirect_back_no_access_right unless params[:id].present?
    retur = Retur.find params[:id]
    return redirect_back_no_access_right unless retur.present?
    return redirect_back_no_access_right if retur.date_approve.present?
    ReturItem.where(retur_id: params[:id]).destroy_all
    retur.destroy
    return redirect_to returs_path
  end

  private
    def retur_items
      items = []
      params[:retur][:retur_items].each do |item|
        items << item[1].values
      end
      items
    end

    def decrease_stock retur_id
      retur_items = ReturItem.where(retur_id: retur_id)
      retur_items.each do |retur_item|
        confirmation = retur_item.accept_item
        item = StoreItem.find_by(item_id: retur_item.item.id, store_id: current_user.store.id)
        new_stock = item.stock.to_i - confirmation.to_i
        item.stock = new_stock
        item.save!
      end
    end

    def param_page
      params[:page]
    end

end
