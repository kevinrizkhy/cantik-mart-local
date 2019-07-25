class ItemsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  
  def index
    # insert_prod = InsertProdlist.new
    # insert_prod.read
    
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

  def show
    return redirect_back_data_not_found items_path unless params[:id].present?
    @item = Item.find_by_id params[:id]
    return redirect_back_data_not_found items_path unless @item.present?
  end

  def new
    @item_cats = ItemCat.all
  end

  def create
    item = Item.new item_params
    return redirect_back_data_invalid new_item_path if item.invalid?
    item.save!
    item.create_activity :create, owner: current_user
    return redirect_success items_path

  end

  def edit
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
    item.create_activity :edit, owner: current_user
    return redirect_success items_path
  end

  def destroy
    return redirect_back_data_not_found items_path unless params[:id].present?
    item = Item.find_by_id params[:id]
    return redirect_back_data_not_found items_path unless item.present?
    if item.store_items.present? || item.supplier_items.present?
      return redirect_back_data_invalid items_path
    else
      item.destroy
      return redirect_success items_path
    end
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
end
