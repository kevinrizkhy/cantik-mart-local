class ItemCatsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    @item_cats = ItemCat.page param_page
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      search_arr = search.split(":")
      if search_arr.size == 2
        @item_cats = @item_cats.where("lower(name) like ?", search)
      else
        @item_cats = @item_cats.where("lower(name) like ?", search)
      end
    end
  end

  def show
    return redirect_back_data_not_found item_cats_path unless params[:id].present?
    @item_cat = ItemCat.find_by_id params[:id]
    return redirect_back_data_invalid new_item_cat_path unless @item_cat.present?
  end

  def new
    @item_cats = ItemCat.all
  end

  def create
    item_cat = ItemCat.new item_cat_params
    item_name = params[:item_cat][:name].camelize
    item_cat.name = item_name
    return redirect_back_data_invalid new_item_cat_path if item_cat.invalid?
    item_cat.save!
    item_cat.create_activity :create, owner: current_user
    return redirect_success item_cats_path
  end

  def edit
    return redirect_back_data_not_found item_cats_path unless params[:id].present?
    @item_cat = ItemCat.find_by_id params[:id]
    return redirect_back_data_invalid new_item_cat_path unless @item_cat.present?
  end

  def update
    return redirect_back_data_not_found item_cats_path unless params[:id].present?
    item_cat = ItemCat.find_by_id params[:id]
    item_cat.assign_attributes item_cat_params
    item_name = params[:item_cat][:name].camelize
    item_cat.name = item_name
    item_cat.save! if item_cat.changed?
    item_cat.create_activity :edit, owner: current_user
    return redirect_success item_cats_path
  end

  def destroy
    return redirect_back_data_not_found item_cats_path unless params[:id].present?
    item_cat = ItemCat.find params[:id]
    return redirect_back_data_not_found item_cats_path unless item_cat.present?
    return redirect_back_data_not_found item_cats_path if item_cat.item.present?
    item_cat.destroy
    return redirect_success item_cats_path
  end

  private
    def item_cat_params
      params.require(:item_cat).permit(
        :name
      )
    end

    def param_page
      params[:page]
    end
end
