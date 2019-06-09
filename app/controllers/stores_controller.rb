class StoresController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
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
    store.name = params[:store][:name].camelize
    store.address = params[:store][:address].camelize
    return redirect_back_data_invalid stores_path if store.invalid?
    supplier = Supplier.new pic: "GUDANG - "+params[:store][:name],
      phone: params[:store][:phone],
      address: params[:store][:address],
      supplier_type: 1
    return redirect_back_data_invalid stores_path if supplier.invalid?
    store.save!
    supplier.save!
    store.create_activity :create, owner: current_user
    supplier.create_activity :create, owner: current_user
    return redirect_success stores_path
  end

  def edit
    return redirect_back_data_not_found stores_path unless params[:id].present?
    @store = Store.find_by_id params[:id]
    return redirect_success stores_path unless @store.present?
  end

  def update
    return redirect_back_data_not_found stores_path unless params[:id].present?
    store = Store.find_by_id params[:id]
    return redirect_back_data_not_found stores_path unless store.present?
    store.assign_attributes store_params
    store.name = params[:store][:name].camelize
    store.address = params[:store][:address].camelize
    store.save! if store.changed?
<<<<<<< HEAD
    store.create_activity :create, owner: current_user
=======
    store.create_activity :edit, owner: current_user
>>>>>>> 8e2056969e4d407ad93d48ffa3e38012fb18c238
    return redirect_success stores_path
  end

  def show
    return redirect_back_data_not_found members_path unless params[:id].present?
    @store = Store.find_by_id params[:id]
    return redirect_back_data_not_found members_path unless @store.present?
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
