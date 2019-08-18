class RetursController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    @returs = Retur.order("date_created DESC").page param_page
    @returs_new = Retur.where('date_approve is null')
      .order("date_created DESC").page(param_page).per(5)
    @returs_complete = Retur.where('status is not null')
      .order("date_created DESC").page param_page
    @returs_picked = Retur.where('date_picked is not null AND status is null')
      .order("date_created DESC").page param_page
    @returs_waiting = Retur.where('date_approve is not null AND date_picked is null')
      .order("date_created DESC").page param_page

    if (current_user.level != User::OWNER) || (current_user.level != User::SUPER_ADMIN)
      @returs = @returs.where(store: current_user.store)
      @returs_new = @returs_new.where(store: current_user.store)
      @returs_complete = @returs_complete.where(store: current_user.store)
      @returs_picked = @returs_picked.where(store: current_user.store)
      @returs_waiting =  @returs_waiting.where(store: current_user.store)
    end

    if params[:search].present?
      search = params[:search].downcase
      @search = search
      search_arr = search.split(":")
      if search_arr.size > 2
        return redirect_back_data_error returs_path, "Data Tidak Valid"
      elsif search_arr.size == 2
        store = Store.where('lower(name) like ?', "%"+search_arr[1].downcase+"%").pluck(:id)
        supplier = Supplier.where('lower(pic) like ?', "%"+search_arr[1].downcase+"%").pluck(:id)
          if search_arr[0]== "to" && supplier.present?
            @returs = @returs.where(supplier_id: supplier)
            @returs_new = @returs_new.where(supplier_id: supplier)
            @returs_complete = @returs_complete.where(supplier_id: supplier)
            @returs_picked = @returs_picked.where(supplier_id: supplier)
            @returs_waiting =  @returs_waiting.where(supplier_id: supplier)
          elsif search_arr[0]== "from" && store.present?
            @returs = @returs.where(store_id: store)
            @returs_new = @returs_new.where(store_id: store)
            @returs_complete = @returs_complete.where(store_id: store)
            @returs_picked = @returs_picked.where(store_id: store)
            @returs_waiting =  @returs_waiting.where(store_id: store)
          else
            @returs = @returs.where("invoice like ?", "%"+ search_arr[1]+"%")
            @returs_new = @returs_new.where("invoice like ?", "%"+ search_arr[1]+"%")
            @returs_complete = @returs_complete.where("invoice like ?", "%"+ search_arr[1]+"%")
            @returs_picked = @returs_picked.where("invoice like ?", "%"+ search_arr[1]+"%")
            @returs_waiting =  @returs_waiting.where("invoice like ?", "%"+ search_arr[1]+"%")
          end
      else
        @returs = @returs.where("invoice like ?", "%"+ search+"%")
        @returs_new = @returs_new.where("invoice like ?", "%"+ search+"%")
        @returs_complete = @returs_complete.where("invoice like ?", "%"+ search+"%")
        @returs_picked = @returs_picked.where("invoice like ?", "%"+ search+"%")
        @returs_waiting =  @returs_waiting.where("invoice like ?", "%"+ search+"%")
      end
    end
  end

  def new
    @suppliers = Supplier.select(:id, :pic, :address).order("supplier_type DESC").all
    if params[:item_id].present?
      @supplier_items = SupplierItem.where(item_id: params[:item_id])
      if @supplier_items.count > 1
        urls = item_suppliers_path(id: params[:item_id])
        return redirect_back_data_error urls, "Data Barang Supplier Tidak Ditemukan"
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
    return redirect_back_data_error new_retur_path, "Data Item Tidak Boleh Kosong" if items.empty?
    total_item = items.size
    address_to = params[:retur][:supplier_id]

    retur = Retur.create invoice: invoice,
      total_items: total_item,
      store_id: current_user.store.id,
      date_created: Time.now,
      supplier_id: address_to,
      user: current_user.id
    
    retur.create_activity :create, owner: current_user
    items.each do |retur_item|
      item = StoreItem.find_by(item_id:retur_item[0], store: current_user.store)
      if item.nil? 
        ReturItem.where(retur: retur).delete_all
        retur.delete
        return redirect_back_data_error new_retur_path, "Data Barang Retur Tidak Tersedia di Toko"
      elsif item.stock < retur_item[1].to_i
        ReturItem.where(retur: retur).delete_all
        retur.delete
        return redirect_back_data_error new_retur_path, "Data Jumlah Barang Retur Melebihi Jumlah Stok Toko"
      end

      ReturItem.create item_id: retur_item[0], retur_id: retur.id, quantity: retur_item[1], description: retur_item[2]
    end
    urls = retur_path id: retur.id
    return redirect_success urls, "Data Retur Telah Disimpan"
  end

  def confirmation
    return redirect_back_data_error returs_path unless params[:id].present?
    @retur = Retur.find params[:id]
    return redirect_back_data_error returs_path if @retur.nil?
    return redirect_back_data_error returs_path if @retur.date_picked.present? || @retur.date_approve.present?
    @retur_items = ReturItem.where(retur_id: @retur.id)
  end

  def accept
    return redirect_back_data_error returs_path, "Data Retur Tidak Ditemukan" unless params[:id].present?
    retur = Retur.find params[:id]
    return redirect_back_data_error returs_path, "Data Retur Tidak Ditemukan" if retur.nil?
    return redirect_back_data_error returs_path, "Data Retur Tidak Valid" if retur.date_picked.present? || retur.date_approve.present?
    items = retur_items
    items.each do |item|
      retur_item = ReturItem.find item[0]
      break if retur_item.nil?
      break if retur_item.quantity < item[1].to_i
      retur_item.accept_item = item[1]
      retur_item.save!
    end
    retur.date_approve = Time.now
    retur.approved_by = current_user.id
    retur.save!
    return redirect_success retur_items_path(id: params[:id])
  end

  def picked
    return redirect_back_data_error returs_path, "Data Retur Tidak Ditemukan" unless params[:id].present?
    retur = Retur.find params[:id]
    return redirect_back_data_error returs_path, "Data Retur Tidak Ditemukan" if retur.nil?
    return redirect_back_data_error returs_path, "Data Retur Tidak Valid" unless retur.date_picked.present? || retur.date_approve.present?
    retur.date_picked = Time.now
    retur.picked_by = current_user.id
    retur.save!
    decrease_stock params[:id]
    return redirect_success returs_path
  end

  def destroy
    return redirect_back_data_error returs_path, "Data Retur Tidak Ditemukan" unless params[:id].present?
    retur = Retur.find params[:id]
    return redirect_back_data_error returs_path, "Data Retur Tidak Ditemukan" unless retur.present?
    return redirect_back_data_error returs_path, "Data Retur Tidak Valid" if retur.date_approve.present?
    ReturItem.where(retur_id: params[:id]).destroy_all
    retur.destroy
    return redirect_success returs_path
  end

  def show
    return redirect_back_data_error returs_path, "Data Retur Tidak Ditemukan" unless params[:id].present?
    @retur = Retur.find_by_id params[:id]
    return redirect_back_data_error returs_path, "Data Retur Tidak Ditemukan" unless @retur.present?
  end

  private
    def retur_items
      items = []
      if params[:retur][:retur_items].present?
        params[:retur][:retur_items].each do |item|
          items << item[1].values
        end
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
