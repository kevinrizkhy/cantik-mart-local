class SuppliersController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    @suppliers = Supplier.page param_page
    @suppliers = @suppliers.where(supplier_type: 0)
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      @suppliers = @suppliers.where("lower(pic) like ? OR phone like ?", search, search)
    end
  end

  def show
    return redirect_back_data_not_found suppliers_path, "Data Supplier Tidak Ditemukan" unless params[:id].present?
    @supplier = Supplier.find_by_id params[:id]
    return redirect_back_data_not_found suppliers_path, "Data Supplier Tidak Ditemukan" unless @supplier.present?
  end

  def new
  end

  def create
    supplier = Supplier.new supplier_params
    supplier.name = params[:supplier][:name].camelize
    supplier.address = params[:supplier][:address].camelize
    return redirect_back_data_not_found new_supplier_path, "Data Supplier Tidak Ditemukan" if supplier.invalid?
    supplier.save!
    supplier.create_activity :create, owner: current_user
    return redirect_success suppliers_path, "Data Supplier - " + supplier.name + " - Berhasil Ditambahkan"
  end

  def edit
    return redirect_back_data_not_found suppliers_path, "Data Supplier Tidak Ditemukan" unless params[:id].present?
    @supplier = Supplier.find_by_id params[:id]
    return redirect_back_data_not_found suppliers_path, "Data Supplier Tidak Ditemukan" unless @supplier.present?
  end

  def update
    return redirect_back_data_not_found suppliers_path, "Data Supplier Tidak Ditemukan" unless params[:id].present?
    supplier = Supplier.find_by_id params[:id]
    return redirect_back_data_not_found suppliers_path, "Data Supplier Tidak Ditemukan" unless supplier.present?
    supplier.assign_attributes supplier_params
    supplier.name = params[:supplier][:name].camelize
    supplier.address = params[:supplier][:address].camelize
    supplier.save! if supplier.changed?
    supplier.create_activity :edit, owner: current_user
    return redirect_success suppliers_path, "Data Supplier - " + supplier.name + " - Berhasil Diubah"
  end

  def destroy
    return redirect_back_data_not_found suppliers_path, "Data Supplier Tidak Ditemukan" unless params[:id].present?
    supplier = Supplier.find_by_id params[:id]
    return redirect_back_data_invalid new_supplier_path, "Data Supplier Tidak Ditemukan" unless supplier.present?
    if supplier.supplier_items.present? || supplier.orders.present? 
      return redirect_back_data_invalid suppliers_path, "Data Supplier Tidak Ditemukan"
    else
      supplier.destroy
      return redirect_success suppliers_path, "Data Supplier - " + supplier.name + " - Berhasil Dihapus" 
    end
  end

  private
    def supplier_params
      params.require(:supplier).permit(
        :name, :address, :phone
      )
    end

    def param_page
      params[:page]
    end

end
