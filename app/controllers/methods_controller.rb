class MethodsController < ApplicationController
  before_action :require_login

  def index
    return redirect_back_data_not_found if params[:id].nil?
  	@methods = ControllerMethod.where(controller_id: params[:id]).order("name ASC").page param_page
  end

  def edit
  	return redirect_back_data_not_found controllers_path unless params[:id].present?
    @method = ControllerMethod.find_by_id params[:id]
    return redirect_back_data_not_found controllers_path unless @method.present?
  end

  def update
    return redirect_back_data_not_found controllers_path unless params[:id].present?
    @method = ControllerMethod.find_by_id params[:id]
    return redirect_back_data_not_found controllers_path unless @method.present?
    user_method = UserMethod.where(controller_method: @method)
    user_method.delete_all if user_method.present?
    UserMethod.create controller_method: @method, user_level: 'owner'
    UserMethod.create controller_method: @method, user_level: 'super_admin'
    new_access_levels = params[:method][:access_levels]
    new_access_levels.each do |access_level|
      level = User.levels.key(access_level.to_i)
      next if level.nil?
      UserMethod.create controller_method: @method, user_level: level
    end
    return redirect_success methods_path(id: @method.controller.id)
  end

  private
  	def param_page
      params[:page]
    end
end