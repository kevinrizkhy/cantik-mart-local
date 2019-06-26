class GrocerItemsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  
  def new
    return redirect_back_data_not_found items_path unless params[:id].present?
    item = Item.find_by_id params[:id]
    return redirect_back_data_invalid new_grocer_item_path unless item.present?
    @id = item.id
    @name = item.name
  end

  def create
    return redirect_back_data_not_found items_path unless params[:id].present?
    item = Item.find_by_id params[:id]
    return redirect_back_data_invalid new_grocer_item_path unless item.present?
    grocer_item = GrocerItem.new grocer_item_params
    grocer_item.item = item
    min = grocer_item.min
    max = grocer_item.max
    grocer = GrocerItem.where(item: item)
    if min < 2
      return redirect_back_data_invalid new_grocer_item_path
    else
      if min > max 
        return redirect_back_data_invalid new_grocer_item_path
      else
        check_same_value = grocer.where("max = ? OR max = ? OR min = ? OR min = ?", min, max, min, max)
        if check_same_value.present?
          return redirect_back_data_invalid new_grocer_item_path
        else
          check_same_value = grocer.where("min < ? AND max > ? ", min, min)
          binding.pry
          if check_same_value.present?
            return redirect_back_data_invalid new_grocer_item_path
          else
            check_same_value = grocer.where("min < ? AND max > ? ", max, max)
            if check_same_value.present?
              return redirect_back_data_invalid new_grocer_item_path
            end
          end
        end
      end
    end
    return redirect_back_data_invalid new_grocer_item_path if grocer_item.invalid?
    grocer_item.save!
    grocer_item.create_activity :create, owner: current_user
    return redirect_success item_path(id: item.id)
  end

  def edit
    return redirect_back_data_not_found item_cats_path unless params[:id].present?
    @grocer_item = GrocerItem.find_by_id params[:id]
    return redirect_back_data_invalid new_item_cat_path unless @grocer_item.present?
  end

  def update
    return redirect_back_data_not_found items_path unless params[:id].present?
    grocer_item = GrocerItem.find_by_id params[:id]
    return redirect_back_data_invalid new_grocer_item_path unless grocer_item.present?
    grocer_item.assign_attributes grocer_item_params
    min = grocer_item.min
    max = grocer_item.max
    grocer = GrocerItem.where(item: grocer_item.item)
    if min < 2
      return redirect_back_data_invalid new_grocer_item_path
    else
      if min > max 
        return redirect_back_data_invalid new_grocer_item_path
      else
        check_same_value = grocer.where("min < ? AND max > ? ", max, max)
        if check_same_value.present?
          return redirect_back_data_invalid new_grocer_item_path
        else
          check_same_value = grocer.where("min < ? AND max > ? ", min, min)
          if check_same_value.present?
            return redirect_back_data_invalid new_grocer_item_path
          else
            check_same_value = grocer.where("max = ? OR max = ? OR min = ? OR min = ?", min, max, min, max)
            if check_same_value.present?
              return redirect_back_data_invalid new_grocer_item_path if grocer_item.invalid?
              grocer_item.save!
              grocer_item.create_activity :create, owner: current_user
              return redirect_success item_path(id: grocer_item.item.id)
            end
          end
        end
      end
    end
  end

  private
    def grocer_item_params
      params.require(:grocer_item).permit(
        :min, :max, :price
      )
    end

    def param_page
      params[:page]
    end
end
