class ItemsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  
  def index
    # insert_prod = InsertProdlist.new
    # insert_prod.read

    @search = params[:search]
    @items = Item.page param_page

    if params[:search_by] == "name"
      @items = Item.search_by_name :name, @search
      @items = @items.page param_page 
    elsif params[:search_by] == "code"
      @items = Item.search_by_code_s :code, @search
      @items = @items.page param_page
    end

    @items = @items.order(name: :asc) if @items.present?

  end

  def show
    return redirect_back_data_error items_path, "Data Barang Tidak Ditemukan" unless params[:id].present?
    @item = Item.find_by_id params[:id]
    return redirect_back_data_error items_path, "Data Barang Tidak Ditemukan" unless @item.present?
  end

  def new
    @item_cats = ItemCat.all
  end

  def create
    item = Item.new item_params
    return redirect_back_data_error new_item_path, "Data Barang Tidak Valid" if item.invalid?
    item.save!
    item.create_activity :create, owner: current_user
    urls = item_path id: item.id
    return redirect_success urls, "Data Barang Berhasil Ditambahkan"

  end

  def edit
    return redirect_back_data_error items_path, "Data Barang Tidak Ditemukan" unless params[:id].present?
    @item = Item.find_by_id params[:id]
    return redirect_back_data_error items_path, "Data Barang Tidak Ditemukan" unless @item.present?
    @item_cats = ItemCat.all
  end

  def update
    return redirect_back_data_error items_path, "Data Barang Tidak Ditemukan" unless params[:id].present?
    item = Item.find_by_id params[:id]
    item.assign_attributes item_params
    changes = item.changes
    item.save! if item.changed?
    item.create_activity :edit, owner: current_user, params: changes
    urls = item_path id: item.id
    return redirect_success urls, "Data Barang - " + item.name + " - Berhasil Diubah"
  end

  def destroy
    return redirect_back_data_error items_path, "Data Barang Tidak Ditemukan" unless params[:id].present?
    item = Item.find_by_id params[:id]
    return redirect_back_data_error items_path, "Data Barang Tidak Ditemukan" unless item.present?
    if item.store_items.present? || item.supplier_items.present?
      return redirect_back_data_error items_path, "Data Barang Tidak Valid"
    else
      item.destroy
      return redirect_success items_path, "Data Barang - " + item.name + " - Berhasil Dihapus"
    end
  end

  private
    def item_params
      params.require(:item).permit(
        :name, :code, :item_cat_id, :buy, :sell, :brand, :discount
      )
    end

    def param_page
      params[:page]
    end
end
