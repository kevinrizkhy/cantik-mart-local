class ReturItemsController < ApplicationController
  before_action :require_login
  def index
    return redirect_back_data_not_found returs_path unless params[:id].present?
    @retur_items = ReturItem.page param_page
    @retur_items = @retur_items.where(retur_id: params[:id])
  end

  def feedback
    return redirect_back_data_not_found returs_path unless params[:id].present?
    @retur = Retur.find params[:id]
    return redirect_back_data_not_found returs_path unless @retur.present?
    return redirect_back_data_not_found returs_path if @retur.status.present?
    @retur_items = ReturItem.where(retur_id: @retur.id)
  end

  def feedback_confirmation
    return redirect_back_data_not_found returs_path unless params[:id].present?
    retur = Retur.find params[:id]
    return redirect_back_data_not_found returs_path unless retur.present?
    return redirect_back_data_invalid returs_path if retur.status.present?
    feed_value = feedback_value
    order = nil
    receivable = nil
    cash_flow = nil
    feed_value.each do |value|
      retur_item = ReturItem.find value[1]
      if retur_item.nil?
          receivable.delete
          OrderItem.where(order: order).delete_all
          order.delete
          break
      end
      if value[0] == "retur_item"
        if order.nil?
          order = Order.create supplier_id: retur.supplier_id, 
            store: current_user.store, 
            total_items: 1,
            total: 0,
            date_created: DateTime.now,
            invoice: "ORDR-" + Time.now.to_i.to_s, 
            editable: false
        end
        if retur_item.nil?
          OrderItem.where(order: order).delete_all
          order.delete
          break
        else
          OrderItem.create quantity: retur_item.quantity, 
          price: 0,
          item_id: value[1],
          order: order,
          description: "RETUR #"+retur.invoice
          retur_item.ref_id = order.id
        end
      elsif value[0] == "cash"
        if receivable.nil?
          receivable = Receivable.create user: current_user, store: current_user.store, nominal: value[2], date_created: DateTime.now, 
                        description: "RECEIVABLE FROM RETUR #"+retur.invoice, finance_type: Receivable::RETUR, deficiency:value[2], to_user: retur.supplier_id
        else
          receivable.nominal += receivable.nominal+value[2]
          receivable.deficiency += receivable.deficiency+value[2]
          receivable.save!
        end
        retur_item.ref_id = receivable.id
        retur_item.nominal = receivable.nominal
      end
      retur_item.feedback = value[0]
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
