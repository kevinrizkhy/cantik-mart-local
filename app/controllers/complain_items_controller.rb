class ComplainItemsController < ApplicationController
  before_action :require_login
  def index
    return redirect_back_data_not_found complains_path unless params[:id].present?
    @complain_items = ComplainItem.page param_page
    @complain_items = @complain_items.where(complain_id: params[:id])
  end

  private
    def param_page
      params[:page]
    end
end
