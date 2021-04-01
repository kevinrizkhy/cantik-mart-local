class AbsentsController < ApplicationController
  before_action :require_login

  def index
    status = SyncData.get_absents
    if !status
      @status = "Fingerprint tidak terhubung."
    end
    @search_text = "Pencarian  "
    @absents = Absent.page param_page

    if ["owner", "super_admin", "finance"].include? current_user.level 
      if params[:id].present?
        @search_id = params[:id]
        @absents = @absents.where(user_id: params[:id])
      end

      if params[:search].present?
        search = "%"+params[:search]+"%".downcase
        @search_text+= " '"+params[:search]+"' "
        users = User.where("lower(name) like ?", search).pluck(:id)
        @absents = @absents.where(user_id: users)
      end

      if params[:date_search].present?
        @search_date = params[:date_search].to_date
        @search_text+= "tanggal "+@search_date.to_s
        @absents = @absents.where("DATE(check_in) = ?", @search_date)
      end
    else
      @absents = @absents.where(user: current_user)
    end
  end

  

  def show
    return redirect_back_data_error absents_path unless params[:id].present?
    @absents = Absent.find_by_id params[:id]
    return redirect_back_data_error absents_path unless @absents.present?
  end

  private
  	def param_page
      params[:page]
    end
end