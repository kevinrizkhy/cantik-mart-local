class TransfersController < ApplicationController
  before_action :require_login
  def index
    @transfers = Transfer.page param_page
    if params[:search].present?
      search = params[:search].downcase
      @search = search
      search_arr = search.split(":")
      if search_arr.size > 2
        return redirect_back_no_access_right
      elsif search_arr.size == 2
        store = Store.where('lower(name) like ?', "%"+search_arr[1].downcase+"%").pluck(:id)
        if store.present?
          if search_arr[0]== "to"
            @transfers = @transfers.where(to_store_id: store)
          elsif search_arr[1]== "from"
            @transfers = @transfers.where(from_store_id: store)
          else
            @transfers = @transfers.where("invoice like ?", "%"+ search_arr[1]+"%")
          end
        end
      else
        @transfers = @transfers.where("invoice like ?", "%"+ search+"%")
      end
    end
  end

  def new
    @stores = Store.all
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
    invoice = "TRF-" + Time.now.to_i.to_s
    items = transfer_items
    total_item = items.size
    to_store = params[:transfer][:store_id]

    transfer = Transfer.create invoice: invoice,
      total_items: total_item,
      from_store_id: current_user.store.id,
      date_created: Time.now,
      to_store_id: to_store

    items.each do |item|
      check_item = Item.find item[0]
      next if check_item.nil?
      qty = item[1].to_i
      next if qty < 1
      TransferItem.create item_id: item[0], transfer_id: transfer.id, request_quantity: qty, description: item[2]
    end
    return redirect_to transfers_path
  end

  def confirmation
    return redirect_back_no_access_right unless params[:id].present?
    @transfer = Transfer.find params[:id]
    return redirect_to transfers_path unless @transfer.present?
    return redirect_to transfers_path if @transfer.date_approve.present?
    @transfer_items = TransferItem.where(transfer_id: @transfer.id)
  end

  def accept
    return redirect_back_no_access_right unless params[:id].present?
    transfer = Transfer.find params[:id]
    return redirect back_no_access_right unless transfer.present?
    return redirect_back_no_access_right if transfer.date_confirm.present? || transfer.date_picked.present?
    if params[:retur][:cancel].present?
      transfer.date_approve = DateTime.now
      transfer.date_picked = "01-01-1999".to_date
      transfer.status = "01-01-1999".to_date
    else
      transfer.date_approve = DateTime.now
    end
    
    transfer.save!
    return redirect_to transfers_path id: params[:id]
  end

  def picked
    return redirect_back_no_access_right unless params[:id].present?
    @transfer = Transfer.find params[:id]
    return redirect_back_no_access_right unless @transfer.present?
    return redirect_back_no_access_right if @transfer.date_approve.nil? || @transfer.date_picked.present?
    @transfer_items = TransferItem.where(transfer_id: @transfer.id)
  end

  def sent
    return redirect_back_no_access_right unless params[:id].present?
    transfer = Transfer.find params[:id]
    return redirect_back_no_access_right if transfer.nil?
    return redirect_back_no_access_right unless transfer.to_store_id == current_user.store.id
    return redirect_back_no_access_right if transfer.date_picked.present? || transfer.status.present?
    transfer.date_picked = DateTime.now
    transfer.save!
    sent_items params[:id]
    return redirect_to transfers_path
  end

  def receive
    return redirect_back_no_access_right unless params[:id].present?
    @transfer = Transfer.find params[:id]
    return redirect_back_no_access_right unless @transfer.present?
    return redirect_back_no_access_right if @transfer.date_approve.nil? || @transfer.date_picked.nil?|| @transfer.status.present?
    @transfer_items = TransferItem.where(transfer_id: @transfer.id)
  end

  def received
    return redirect_back_no_access_right unless params[:id].present?
    transfer = Transfer.find params[:id]
    return redirect_back_no_access_right if transfer.nil?
    return redirect_back_no_access_right unless transfer.from_store_id == current_user.store.id
    return redirect_back_no_access_right if transfer.date_picked.nil? || transfer.date_approve.nil? || transfer.status.present?
    transfer.status = DateTime.now
    transfer.save!
    receive_items params[:id]
    return redirect_to transfers_path
  end

  def destroy
    return redirect_back_no_access_right unless params[:id].present?
    retur = Transfer.find params[:id]
    return redirect_back_no_access_right unless retur.present?
    return redirect_back_no_access_right if retur.date_approve.present?
    TransferItem.where(retur_id: params[:id]).destroy_all
    retur.destroy
    return redirect_to transfers_path
  end

  private
    def transfer_items
      items = []
      params[:transfer][:transfer_items].each do |item|
        items << item[1].values
      end
      items
    end

    def sent_items transfer_id
      transfer_items.each do |item|
        transfer_item = TransferItem.find item[2]
        store_item = StoreItem.find_by(item_id: item[0], store_id: current_user.store.id)
        qty = item[1].to_i
        if store_item.present?
          if transfer_item.request_quantity < qty
            qty = transfer_item.request_quantity
          end
        else
          qty = 0
        end
        transfer_item.sent_quantity = qty
        transfer_item.save!
        next if store_item.nil?
        new_stock = store_item.stock.to_i - qty
        store_item.stock = new_stock
        store_item.save!
      end
    end

    def receive_items transfer_id
      transfer_items.each do |item|
        transfer_item = TransferItem.find item[2]
        qty = item[1].to_i.abs
        transfer_item.receive_quantity = qty
        transfer_item.save!
        store_item = StoreItem.find_by(item_id: item[0], store_id: current_user.store.id)
        if store_item.nil?
          StoreItem.create store: current_user.store, item_id: item[0], stock: qty
        else
          store_item.stock =  store_item.stock.to_i + qty
          store_item.save!
        end
      end
    end

    def param_page
      params[:page]
    end

end
