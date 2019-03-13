class ItemSuppliersController < ApplicationController
  before_action :require_login
  def index
    return redirect_back_no_access_right unless params[:id].present?
    @inventories = SupplierItem.page param_page
    @item = Item.find_by_id params[:id]
    return redirect_to items_path unless @item.present?
    @inventories = @inventories.where(item_id: @item.id)
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      supplier = Supplier.where('lower(name) like ? OR code like ?', search, search).pluck(:id)
      @inventories = @inventories.where(supplier_id: supplier)
    end
  end

  private
    def param_page
      params[:page]
    end
end
