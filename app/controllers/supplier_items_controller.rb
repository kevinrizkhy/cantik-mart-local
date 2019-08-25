class SupplierItemsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    return redirect_back_data_error suppliers_path, "Data Barang Suplier Tidak Ditemukan" unless params[:id].present?
    # @inventories = SupplierItem.page param_page
    @supplier = Supplier.find_by_id params[:id]
    # return redirect_back_data_error suppliers_path, "Data Barang Suplier Tidak Ditemukan" unless @supplier.present?
    # @inventories = @inventories.where(supplier_id: @supplier.id)
    # if params[:search].present?
    #   @search = params[:search].downcase
    #   search = "%"+@search+"%"
    #   items = Item.where('lower(name) like ? OR code like ?', search, search).pluck(:id)
    #   @inventories = @inventories.where(item_id: items)
    # end
    @order_items = OrderItem.where(order: Order.where(supplier: @supplier).pluck(:id)).select(:item_id, :quantity).page param_page
    @inventories = @order_items.group(:item_id).sum(:quantity)
    @inventories = @inventories.sort_by(&:last).reverse
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
