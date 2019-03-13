class StoresController < ApplicationController
  before_action :require_login
  def index
    @stores = Store.page param_page
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      @stores = @stores.where("lower(name) like ? OR phone like ?", search, search)
    end
  end

  def new

  end

  def create
    store = Store.new store_params
    return redirect_to new_store_path if store.invalid?

    supplier = Supplier.new pic: "GUDANG - "+params[:store][:name],
      phone: params[:store][:phone],
      address: params[:store][:address],
      supplier_type: 1
    return redirect_to new_store_path if supplier.invalid?

    store.save!
    supplier.save!
    return redirect_to stores_path
  end

  def edit
    return redirect_back_no_access_right unless params[:id].present?
    @store = Store.find_by_id params[:id]
    return redirect_to stores_path unless @store.present?
  end

  def update
    return redirect_back_no_access_right unless params[:id].present?
    store = Store.find_by_id params[:id]
    return redirect_to stores_path unless store.present?
    store.assign_attributes store_params
    store.save! if store.changed?
    return redirect_to stores_path
  end

  private
    def store_params
      params.require(:store).permit(
        :name, :address, :phone, :store_type
      )
    end

    def param_page
      params[:page]
    end

end
