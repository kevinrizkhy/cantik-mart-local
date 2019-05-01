class ReturItemsController < ApplicationController
  before_action :require_login
  def index
    return redirect_back_no_access_right unless params[:id].present?
    @retur_items = ReturItem.page param_page
    @retur_items = @retur_items.where(retur_id: params[:id])
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
    order = nil
    feed_value.each do |value|
      if value[0] == "retur_item"
        if order.nil?
          order = Order.create supplier_id: retur.supplier_id, 
            store: current_user.store, 
            total_items: 1,
            total: 0,
            date_created: DateTime.now,
            invoice: "ORD-" + Time.now.to_i.to_s
        end
        retur_item = ReturItem.find value[1]
        if retur_item.nil?
          OrderItem.where(order: order).delete_all
          order.delete
          break
        else
          a = OrderItem.create quantity: retur_item.quantity, 
          price: 0,
          item_id: value[1],
          order: order,
          description: "RETUR #"+order.invoice
          binding.pry
        end
      elsif value[0] == "cash"
        binding.pry
      end
      retur_item = ReturItem.find value[1]
      retur_item.feedback = value[0]
      retur_item.nominal = 0
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
