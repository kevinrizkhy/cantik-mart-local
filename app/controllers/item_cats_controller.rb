class ItemCatsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    if params[:dept_id].present?
      @item_cats = ItemCat.page param_page
      @item_cats = @item_cats.where(department_id: params[:dept_id])
      @dept = Department.find_by_id params[:dept_id]
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
    else
      return redirect_back_data_not_found departments_path, "ID Departemen Tidak Ditemukan"
    end
  end

  def show
    return redirect_back_data_not_found departments_path, "ID Departemen Tidak Ditemukan" unless params[:id].present?
    @item_cat = ItemCat.find_by_id params[:id]
    return redirect_back_data_invalid departments_path, "Data Kategori Item Tidak Ditemukan" unless @item_cat.present?
  end

  def new
    return redirect_back_data_not_found departments_path, "ID Departemen Tidak Ditemukan" unless params[:dept_id].present?
    @department = Department.find_by_id params[:dept_id]
    return redirect_back_data_invalid departments_path, "Data Kategori Item Tidak Ditemukan" unless @department.present?
  end

  def create
    item_cat = ItemCat.new item_cat_params
    item_name = params[:item_cat][:name].camelize
    item_cat.name = item_name
    return redirect_back_data_invalid new_item_cat_path, "Data Tidak Lengkap" if item_cat.invalid?
    item_cat.save!
    item_cat.create_activity :create, owner: current_user
    params = "?" + { :dept_id => item_cat.department_id }.to_param
    return redirect_success item_cats_path + params, "Kategori Item - " + item_cat.name + " - Berhasil Disimpan"
  end

  def edit
    return redirect_back_data_not_found departments_path, "Data Kategori Item Tidak Ditemukan" unless params[:id].present?
    @item_cat = ItemCat.find_by_id params[:id]
    return redirect_back_data_invalid item_cats_path, "Data Kategori Item Tidak Ditemukan" unless @item_cat.present?
  end

  def update
    return redirect_back_data_not_found item_cats_path, "Data Kategori Item Tidak Ditemukan" unless params[:id].present?
    item_cat = ItemCat.find_by_id params[:id]
    item_cat.assign_attributes item_cat_params
    item_name = params[:item_cat][:name].camelize
    item_cat.name = item_name
    item_cat.save! if item_cat.changed?
    item_cat.create_activity :edit, owner: current_user
    params = "?" + { :dept_id => item_cat.department_id }.to_param
    return redirect_success item_cats_path + params , "Kategori Item - " + item_cat.name + " Berhasil Diubah"
  end

  def destroy
    return redirect_back_data_not_found departments_path, "Data Kategori Item Tidak Ditemukan" unless params[:id].present?
    item_cat = ItemCat.find params[:id]
    return redirect_back_data_not_found departments_path, "Data Kategori Item Tidak Ditemukan" unless item_cat.present?
    return redirect_back_data_not_found departments_path, "Data Kategori Item Tidak Dapat Dihapus" if item_cat.item.present?
    item_name = item_cat.name
    dept_id = item_cat.department_id
    item_cat.destroy
    params = "?" + { :dept_id => dept_id }.to_param
    return redirect_success item_cats_path + params, "Kategori Item - " + item_name + " - Berhasil Dihapus"
  end

  private
    def item_cat_params
      params.require(:item_cat).permit(
        :name, :department_id
      )
    end

    def param_page
      params[:page]
    end
end
