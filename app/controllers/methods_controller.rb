class MethodsController < ApplicationController
  before_action :require_login

  def index
    return redirect_back_data_not_found if params[:id].nil?
  	@methods = ControllerMethod.where(controller_id: params[:id]).order("name ASC").page param_page
  end

  private
  	def param_page
      params[:page]
    end
end