class SuppliersController < ApplicationController
  before_action :require_login
  def index
    @suppliers = Supplier.page param_page
    @suppliers = @suppliers.where(supplier_type: 0)
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      @suppliers = @suppliers.where("lower(pic) like ? OR phone like ?", search, search)
    end

  end

  def new

  end

  def create
    supplier = Supplier.new supplier_params
    return redirect_to new_supplier_path if supplier.invalid?
    supplier.save!
    return redirect_to suppliers_path
  end

  def edit
    return redirect_back_no_access_right unless params[:id].present?
    @supplier = Supplier.find_by_id params[:id]
    return redirect_to suppliers_path unless @supplier.present?
  end

  def update
    return redirect_back_no_access_right unless params[:id].present?
    supplier = Supplier.find_by_id params[:id]
    return redirect_to suppliers_path unless supplier.present?
    supplier.assign_attributes supplier_params
    supplier.save! if supplier.changed?
    return redirect_to suppliers_path
  end

  private
    def supplier_params
      params.require(:supplier).permit(
        :pic, :address, :phone
      )
    end

    def param_page
      params[:page]
    end

end
