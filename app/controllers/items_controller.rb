class ItemsController < ApplicationController
  before_action :require_login
  def index
    # insert_prod = InsertProdlist.new
    # insert_prod.read
    # insert_prod.update_brand
    @items = Item.page param_page
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      @items = @items.where("lower(name) like ? OR code like ?", search, search)
    end
    if params[:order_by].present? && params[:order_type].present?
      @order_by = params[:order_by].downcase
      order_type = params[:order_type].upcase
      if order_type == "ASC" 
        @order_type = "menaik (A - Z)"
      else
        @order_type = "menurun (Z - A)"
      end
          
      order = @order_by+" "+order_type
      @items = @items.order(order)
    end
  end

  def new
    @item_cats = ItemCat.all
  end

  def create
    item = Item.new item_params
    return redirect_back_data_invalid new_item_path if item.invalid?
    item.save!
    insert_into_all_store item.id
    return redirect_to items_path

  end

  def edit
    @name = "qwerty"
    return redirect_back_data_not_found items_path unless params[:id].present?
    @item = Item.find_by_id params[:id]
    return redirect_back_data_not_found items_path unless @item.present?
    @item_cats = ItemCat.all
  end

  def update
    return redirect_back_data_not_found items_path unless params[:id].present?
    item = Item.find_by_id params[:id]
    item.assign_attributes item_params
    item.save! if item.changed?
    return redirect_to items_path
  end

  private
    def item_params
      params.require(:item).permit(
        :name, :code, :item_cat_id, :buy, :sell, :brand
      )
    end

    def param_page
      params[:page]
    end

    def insert_into_all_store item_id
      stores = Store.all.pluck(:id)
      stores.each do |store_id|
        StoreItem.create item_id: item_id, store_id: store_id
      end
    end
end
