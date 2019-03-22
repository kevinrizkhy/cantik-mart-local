class TransferItemsController < ApplicationController
  before_action :require_login
  def index
    return redirect_back_no_access_right unless params[:id].present?
    @transfer_items = TransferItem.page param_page
    @transfer_items = @transfer_items.where(transfer_id: params[:id])
    @item = Item.page param_page
  end

  private
    def param_page
      params[:page]
    end

end
