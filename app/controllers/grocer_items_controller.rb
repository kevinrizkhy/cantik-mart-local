class GrocerItemsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  
  def new
    return redirect_back_data_not_found grocer_items_path unless params[:id].present?
    item = Item.find_by_id params[:id]
    return redirect_back_data_invalid new_grocer_item_path unless item.present?
    @id = item.id
    @name = item.name
  end

  def create
    return redirect_back_data_not_found grocer_items_path unless params[:id].present?
    item = Item.find_by_id params[:id]
    return redirect_back_data_invalid new_grocer_item_path unless item.present?
    grocer_item = GrocerItem.new grocer_item_params
    grocer_item.item = item
    return redirect_back_data_invalid new_grocer_item_path if grocer_item.invalid?
    grocer_item.save!
    grocer_item.create_activity :create, owner: current_user
    return redirect_success item_path(id: item.id)
  end

  def edit
    return redirect_back_data_not_found item_cats_path unless params[:id].present?
    @item_cat = ItemCat.find_by_id params[:id]
    return redirect_back_data_invalid new_item_cat_path unless @item_cat.present?
  end

  def update
    return redirect_back_data_not_found item_cats_path unless params[:id].present?
    item_cat = ItemCat.find_by_id params[:id]
    item_cat.assign_attributes grocer_item_params
    item_cat.save! if item_cat.changed?
    item_cat.create_activity :edit, owner: current_user
    return redirect_success item_cats_path
  end

  private
    def grocer_item_params
      params.require(:item).permit(
        :min, :max, :price
      )
    end

    def param_page
      params[:page]
    end
end
