class StocksController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    @search = params[:search]
    @inventories = StoreItem.where(store: current_user.store).page param_page

    if params[:search_by] == "name"
      items = Item.search_by_name(:name, @search).order(name: :asc).page param_page 
    elsif params[:search_by] == "code"
      items = Item.search_by_code_s(:code, @search).order(name: :asc).page param_page 
    end

  end

  def edit
    return redirect_back_data_error stocks_path, "Data Stok Barang Tidak Ditemukan" unless params[:id].present?
    @stock = StoreItem.find_by_id params[:id]
    return redirect_back_data_error stocks_path, "Data Stok Barang Tidak Ditemukan" unless @stock.present?
    @item = @stock.item
    @item_cats = ItemCat.all
  end

  def update
    return redirect_back_data_error stocks_path, "Data Stok Barang Tidak Ditemukan" unless params[:id].present?
    item = StoreItem.find_by_id params[:id]
    item.assign_attributes stock_params
    changes = item.changes
    item.save! if item.changed?
    item.create_activity :edit, owner: current_user, parameters: changes
    return redirect_success stocks_path, "Data Stok Barang Berhasil Diubah"
  end

  def show
    return redirect_back_data_error stocks_path, "Data Stok Barang Tidak Ditemukan" unless params[:id].present?
    @stock = StoreItem.find_by_id params[:id]
    return redirect_back_data_error stocks_path, "Data Stok Barang Tidak Ditemukan" unless @stock.present?
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
