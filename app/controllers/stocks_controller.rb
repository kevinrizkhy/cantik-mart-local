class StocksController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    @inventories = StoreItem.page param_page
    @inventories = @inventories.where(store: current_user.store)
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      items = Item.where('lower(name) like ? OR code like ?', search, search).pluck(:id)
      @inventories = @inventories.where(item_id: items)
    end

  end

  def edit
    return redirect_back_data_not_found stocks_path unless params[:id].present?
    @stock = StoreItem.find_by_id params[:id]
    return redirect_back_data_not_found stocks_path unless @stock.present?
    @item = @stock.item
    @item_cats = ItemCat.all
  end

  def update
    return redirect_back_data_not_found stocks_path unless params[:id].present?
    item = StoreItem.find_by_id params[:id]
    item.assign_attributes stock_params
    item.save! if item.changed?
    item.create_activity :edit, owner: current_user
    return redirect_success stocks_path
  end

  def show
    return redirect_back_data_not_found stocks_path unless params[:id].present?
    @stock = StoreItem.find_by_id params[:id]
    return redirect_back_data_not_found stocks_path unless @stock.present?
    @item = @stock.item
  end

  private
    def stock_params
      {
        stock: params[:item][:stock],
        min_stock: params[:item][:min_stock]
      }
    end

    def param_page
      params[:page]
    end
end
