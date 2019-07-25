class DepartmentsController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    @departments = Department.page param_page
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      search_arr = search.split(":")
      if search_arr.size == 2
        @departments = @departments.where("lower(name) like ?", search)
      else
        @departments = @departments.where("lower(name) like ?", search)
      end
    end
  end

  def show
    return redirect_back_data_not_found departments_path unless params[:id].present?
    @department = Department.find_by_id params[:id]
    return redirect_back_data_invalid new_item_cat_path if @department.nil?
    return redirect_to item_cats_path dept_id: @department.id
  end

  def new
    @departments = Department.all
  end

  def create
    department = Department.new department_params
    department_name = params[:department][:name].camelize
    department.name = department_name
    return redirect_back_data_invalid new_item_cat_path if department.invalid?
    department.save!
    department.create_activity :create, owner: current_user
    return redirect_success departments_path
  end

  def edit
    return redirect_back_data_not_found departments_path unless params[:id].present?
    @department = Department.find_by_id params[:id]
    return redirect_back_data_invalid new_item_cat_path unless @department.present?
  end

  def update
    return redirect_back_data_not_found departments_path unless params[:id].present?
    department = Department.find_by_id params[:id]
    department.assign_attributes department_params
    item_name = params[:department][:name].camelize
    department.name = item_name
    department.save! if department.changed?
    department.create_activity :edit, owner: current_user
    return redirect_success departments_path
  end

  def destroy
    return redirect_back_data_not_found departments_path unless params[:id].present?
    department = Department.find params[:id]
    return redirect_back_data_not_found departments_path unless department.present?
    return redirect_back_data_invalid departments_path if department.item_cat.present?
    department.destroy
    return redirect_success departments_path
  end

  private
    def department_params
      params.require(:department).permit(
        :name
      )
    end

    def param_page
      params[:page]
    end
end
