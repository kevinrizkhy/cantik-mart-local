class TransactionsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  skip_before_action :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }


  @@point = 10000

  def index
    # SyncData.check_new_data
    # SyncData.post_local_data
    @transactions = Transaction.page param_page
    if params[:search].present?
      search = params[:search].downcase
      @search = search
      search_arr = search.split(":")
      if search_arr.size > 2
        return redirect_back_data_error transactions_path, "Data Tidak Valid"
      elsif search_arr.size == 2
        store = Store.where('lower(store) like ?', "%"+search_arr[1].downcase+"%").pluck(:id)
          if search_arr[0]== "store" && store.present?
            @transactions = @transactions.where(store_id: store)
          else
            @transactions = @transactions.where("invoice like ?", "%"+ search_arr[1]+"%")
          end
      else
        @transactions = @transactions.where("invoice like ?", "%"+ search+"%")
      end
    end
  end

  def new
    gon.store_id = current_user.store.id

    respond_to do |format|
      format.html { render "transactions/new", :layout => false  } 
    end
  end

  def create_trx
    items = trx_items
    
    item = 0
    discount = 0
    total = 0
    grand_total = 0
    hpp_total = 0

    promotions_code  = []
    items.each do |trx_item|
      item += trx_item[1].to_i
      discount += trx_item[1].to_i * trx_item[3].to_i
      total += trx_item[1].to_i * trx_item[2].to_i
      grand_total += trx_item[4].to_i
      promo = trx_item[5]
      promotions_code << promo if promo.include? "PROMO-"
    end

    trx = Transaction.new
    trx.invoice = "TRX-"+DateTime.now.to_i.to_s+"-"+current_user.store.id.to_s+"-"+current_user.id.to_s
    trx.user = current_user
    member_card = nil
    if params[:member] != ""
      member = Member.find_by(card_number: params[:member].to_i)
      if member.present?
        member_card = member.card_number
      end
    end
    trx.member_card = member_card
    trx.date_created = Time.now
    trx.payment_type = params[:payment].to_i
    trx.store = current_user.store
    trx.voucher = params[:voucher]

    trx.items = item.to_i
    trx.discount = discount.to_i
    trx.total = total.to_i
    trx.grand_total = grand_total.to_i
    trx.tax = 0

    if params[:payment] != 1
      trx.bank = params[:bank].to_i
      trx.edc_inv = params[:edc].to_s
      trx.card_number = params[:card].to_s
    end
    trx.save!
    
    trx_total_for_point = 0
    tax = 0
    items.each do |item_par|
      item = Item.find_by(code: item_par[0])
      next if item.nil?

      item_cats = ItemCat.where(use_in_point: true).pluck(:id)

      if item_cats.include? item.item_cat.id 
        trx_total_for_point += item_par[2].to_i
      end

      trx_item = TransactionItem.create item: item,  
      transaction_id: trx.id,
      quantity: item_par[1], 
      price: item_par[2],
      discount: item_par[3],
      date_created: DateTime.now


      if item.tax != 0
        tax += trx_item.quantity*(trx_item.price-((100.0/ (100.0 + item.tax)*trx_item.price))).to_i
      end

      if trx_item.price == 0
        promo = item_par[5]
        trx_item.reason = promo
        trx_item.save!
      end
      store_stock = StoreItem.find_by(store: current_user.store, item: item)
      hpp_total += (item_par[1].to_i * item.buy).round
      next if store_stock.nil?
      store_stock.stock = store_stock.stock.to_i - item_par[1].to_i
      store_stock.save!
    end
    trx.tax = tax
    trx.hpp_total = hpp_total
    new_point = trx_total_for_point / @@point
    trx.point = new_point
    trx.save!
    render status: 200, json: {
      invoice: trx.invoice.to_s,
      time: trx.created_at.strftime("%d/%m/%Y %H:%M:%S"),
      
    }.to_json
  end

  private
    def trx_items
      items = []
      par_items = params[:items].values
      par_items.each do |item|
        items << item.values
      end
      items
    end

    def decrease_stock trx_id
      
    end

    def param_page
      params[:page]
    end

end
