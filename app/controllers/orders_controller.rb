class OrdersController < ApplicationController
  before_action :require_login
  def index
    @orders = Order.page param_page
    if params[:type].present?
      @type = params[:type]
      if @type == "ongoing" 
        @type = "sedang dalam proses"
        @orders = @orders.where(store_id: current_user.store.id).where('date_receive is null')
      elsif @type == "payment"
        @type = "belum lunas"
        @orders = @orders.where(store_id: current_user.store.id).where('date_receive is not null and date_paid_off is null')
      end
    end
    if params[:search].present?
      search = params[:search].downcase
      @search = search
      search_arr = search.split(":")
      if search_arr.size > 2
        return redirect_back_no_access_right
      elsif search_arr.size == 2
        supplier = Supplier.where('lower(pic) like ?', "%"+search_arr[1].downcase+"%").pluck(:id)
          if search_arr[0]== "supplier" && supplier.present?
            @orders = @orders.where(supplier_id: supplier)
          else
            @orders = @orders.where("invoice like ?", "%"+ search_arr[1]+"%")
          end
      else
        @orders = @orders.where("invoice like ?", "%"+ search+"%")
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
    invoice = "ORD-" + Time.now.to_i.to_s
    item_arr = order_items
    total_item = item_arr.size
    address_to = params[:order][:supplier_id]

    order = Order.create invoice: invoice,
      total_items: total_item,
      store_id: current_user.store.id,
      date_created: Time.now,
      supplier_id: address_to,
      total: 0

    total = 0
    item_arr.each do |item_arr|
      item = Item.find item_arr[0]
      break if item.nil?
      supplier_item = SupplierItem.find_by(item_id: item_arr[0])
      SupplierItem.create supplier_id: address_to, item: item if supplier_item.nil?
      order_item = OrderItem.create item_id: item_arr[0], order_id: order.id, quantity: item_arr[1], price: item_arr[2], description: item_arr[3]
      total+= (item_arr[2].to_i*item_arr[1].to_i)
    end

    order.total = total
    order.save!

    return redirect_to orders_path
  end

   def destroy
    return redirect_back_no_access_right unless params[:id].present?
    order = Order.find params[:id]
    return redirect_back_no_access_right unless order.present?
    return redirect_back_no_access_right if order.date_receive.present?
    OrderItem.where(order_id: params[:id]).destroy_all
    order.destroy
    return redirect_to orders_path
  end

  def confirmation
    return redirect_back_no_access_right unless params[:id].present?
    @order = Order.find params[:id]
    return redirect_back_no_access_right if @order.date_receive.present? || @order.date_paid_off.present?
    return redirect_to orders_path unless @order.present?
    @order_items = OrderItem.where(order_id: @order.id)

  end

  def receive
    return redirect_back_no_access_right unless params[:id].present?
    order = Order.find params[:id]
    return redirect_back_no_access_right unless order.present?
    return redirect_back_no_access_right if order.date_receive.present? || order.date_paid_off.present?
    items = order_items
    new_total = 0
    items.each do |item|
      order_item = OrderItem.find item[0]
      break if order_item.nil?
      order_item.receive = item[1]
      order_item.save!
      this_item = Item.find order_item.item.id
      store_stock = StoreItem.find_by(item_id: order_item.item.id, store_id: current_user.store)
      store_stock = StoreItem.create store: current_user.store, item: this_item, stock: 0, min_stock: 5 if store_stock.nil?
      store_stock.stock = store_stock.stock + item[1].to_i
      store_stock.save!
      new_buy_total = item[1].to_i * order_item.price.to_i
      old_buy_total = store_stock.stock.to_i * this_item.buy.to_i
      new_buy = 0
      new_buy = (new_buy_total + old_buy_total) / (item[1].to_i + store_stock.stock.to_i) if (item[1].to_i + store_stock.stock.to_i) > 0
      this_item.buy = new_buy
      this_item.save!
      new_total +=  new_buy_total
    end
    order.total = new_total
    order.date_receive = Time.now
    order.save!
    
    Debt.create user: current_user, store: current_user.store, nominal: new_total, 
                deficiency: new_total, date_created: DateTime.now, ref_id: order.id,
                description: order.invoice, finance_type: Debt::ORDER
    description = order.invoice + " (" + new_total.to_s + ")"
    CashFlow.create user: current_user, store: current_user.store, nominal: new_total, date_created: DateTime.now, 
                    description: description, finance_type: CashFlow::DEBT
    
    return redirect_to order_items_path(id: params[:id])
  end

  def pay
    return redirect_back_no_access_right unless params[:id].present?
    @order = Order.find params[:id]
    return redirect_back_no_access_right unless @order.present?
    return redirect_back_no_access_right if @order.date_receive.nil? || @order.date_paid_off.present?
    @order_invs = InvoiceTransaction.where(invoice: @order.invoice)
    @pay = @order.total.to_i - @order_invs.sum(:nominal) 
  end

  def paid
    return redirect_back_no_access_right unless params[:id].present?
    order = Order.find params[:id]
    return redirect_back_no_access_right unless order.present?
    return redirect_back_no_access_right if order.date_receive.nil? || order.date_paid_off.present?
    order_invs = InvoiceTransaction.where(invoice: order.invoice)
    paid = order.total.to_f - order_invs.sum(:nominal) 
    return redirect_back_no_access_right if (params[:order_pay][:nominal].to_i > paid) || (params[:order_pay][:nominal].to_i < 0)
    order_inv = InvoiceTransaction.new 
    order_inv.invoice = order.invoice
    order_inv.transaction_type = 0
    order_inv.transaction_invoice = "PAID-" + Time.now.to_i.to_s
    order_inv.date_created = params[:order_pay][:date_paid]
    order_inv.nominal = params[:order_pay][:nominal].to_f
    order_inv.save!
    deficiency = paid - params[:order_pay][:nominal].to_f
    debt = Debt.find_by(finance_type: Debt::ORDER, ref_id: order.id)
    debt.deficiency = deficiency
    if deficiency <= 0
      order.date_paid_off = Time.now 
      order.save!
      debt.deficiency = deficiency
    end
    debt.save!
    return redirect_to order_items_path(id: params[:id])
  end

  private
    def paid_params
      params.require(:order_pay).permit(
        :nominal, :date_paid
      )
    end

    def order_items
      items = []
      params[:order][:order_items].each do |item|
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
