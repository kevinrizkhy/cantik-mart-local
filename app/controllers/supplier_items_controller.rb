class SupplierItemsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    return redirect_back_data_error suppliers_path, "Data Barang Suplier Tidak Ditemukan" unless params[:id].present?
    @inventories = SupplierItem.page param_page
    @supplier = Supplier.find_by_id params[:id]
    return redirect_back_data_error suppliers_path, "Data Barang Suplier Tidak Ditemukan" unless @supplier.present?
    @inventories = @inventories.where(supplier_id: @supplier.id)
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      items = Item.where('lower(name) like ? OR code like ?', search, search).pluck(:id)
      @inventories = @inventories.where(item_id: items)
    end
  end

  def new
    return redirect_back_data_error suppliers_path, "Data Barang Suplier Tidak Ditemukan" unless params[:id].present?
    @supplier = Supplier.find_by_id params[:id]
    items_id = Item.all.pluck(:id)
    supplier_item_exist = SupplierItem.where(supplier_id: params[:id]).pluck(:item_id)
    new_items = items_id - supplier_item_exist
    @items = Item.where(id: new_items)
  end

  def create
    supplier = Supplier.find params[:id]
    return redirect_back_data_error suppliers_path, "Data Barang Suplier Tidak Ditemukan" unless supplier.present?
    supplier_item = SupplierItem.new supplier_item_params
    supplier_item.supplier_id = supplier.id
    return redirect_back_invalid suppliers_path, "Data Barang Suplier Tidak Ditemukan" if supplier_item.invalid?
    supplier_item.save!
    urls = supplier_items_path(id: params[:id])
    return redirect_success urls, "Data Barang Supplier " + supplier.name + " - " + supplier_item.item.name + " - Berhasil Disimpan"
  end

  def edit
    return redirect_back_data_error suppliers_path, "Data Barang Suplier Tidak Ditemukan" unless params[:id].present?
    @stock = StoreItem.find_by_id params[:id]
    return redirect_back_data_error suppliers_path, "Data Barang Suplier Tidak Ditemukan" unless @stock.present?
    @item = @stock.item
    @item_cats = ItemCat.all
  end

  def update
    return redirect_back_data_error suppliers_path, "Data Barang Suplier Tidak Ditemukan" unless params[:id].present?
    item = StoreItem.find_by_id params[:id]
    item.assign_attributes stock_params
    item.save! if item.changed?
    return redirect_success stocks_path
  end

  def show
    return redirect_back_data_error supplier_items_path, "Data Barang Suplier Tidak Ditemukan" unless params[:id].present?
    @supplier_item = SupplierItem.find_by_id params[:id]
    return redirect_back_data_error new_supplier_path, "Data Barang Suplier Tidak Ditemukan" unless @supplier_item.present?
  end

  private
    def supplier_item_params
      params.require(:supplier_item).permit(
        :item_id
      )
    end

    def param_page
      params[:page]
    end
end
