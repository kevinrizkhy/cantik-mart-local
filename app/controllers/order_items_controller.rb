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

  def feedback
    return redirect_back_no_access_right unless params[:id].present?
    @retur = Retur.find params[:id]
    return redirect_to returs_path unless @retur.present?
    return redirect_back_no_access_right if @retur.status.present?
    @retur_items = ReturItem.where(retur_id: @retur.id)
  end

  def feedback_confirmation
    return redirect_back_no_access_right unless params[:id].present?
    retur = Retur.find params[:id]
    return redirect_back_no_access_right unless retur.present?
    return redirect_back_no_access_right if retur.status.present?
    feed_value = feedback_value
    feed_value.each do |value|
      retur_item = ReturItem.find value[1]
      retur_item.feedback = value[0]
      retur_item.nominal = value[2]
      retur_item.save!
    end
    retur.status = Time.now
    retur.save
    return redirect_to retur_items_path(id: retur.id)
  end

  private
    def param_page
      params[:page]
    end

    def feedback_value
      array = []
      params[:retur][:retur_items].each do |item|
        array << item[1].values
      end
      array
    end
end
