class OrderItemsController < ApplicationController
  before_action :require_login
  def index
    return redirect_back_no_access_right unless params[:id].present?
    order = Order.find params[:id]
    return redirect_back_no_access_right unless order.present?
    @order_items = OrderItem.page param_page
    @order_items = @order_items.where(order_id: params[:id])
    @order_invs = InvoiceTransaction.where(invoice: order.invoice)
    @pay = order.total.to_i - @order_invs.sum(:nominal) 
  end

  private
    def param_page
      params[:page]
    end
end
