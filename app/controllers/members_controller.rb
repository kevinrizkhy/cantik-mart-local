class MembersController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint

  def index
    @members = Member.page param_page
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      @members = @members.where("lower(name) like ? OR phone like ?", search, search)
    end
  end

  def new
  end

  def create
    member = Member.new member_params
    member.name = params[:member][:name].camelize
    member.user = current_user
    member.store = current_user.store
    return redirect_back_data_invalid new_member_path if member.invalid?
    member.save!
    member.create_activity :create, owner: current_user
    return redirect_success members_path
  end

  def edit
    return redirect_back_data_not_found members_path unless params[:id].present?
    @member = Member.find_by_id params[:id]
    return redirect_back_data_not_found members_path unless @member.present?
  end

  def update
    return redirect_back_data_not_found unless params[:id].present?
    member = Member.find_by_id params[:id]
    member.assign_attributes member_params
    member.name = params[:member][:name].camelize
    member.save! if member.changed?
<<<<<<< HEAD
    member.create_activity :create, owner: current_user
=======
    member.create_activity :edit, owner: current_user
>>>>>>> 8e2056969e4d407ad93d48ffa3e38012fb18c238
    return redirect_success members_path
  end

  def show
    return redirect_back_data_not_found members_path unless params[:id].present?
    @member = Member.find_by_id params[:id]
    return redirect_back_data_not_found members_path unless @member.present?
  end

  private
    def member_params
      params.require(:member).permit(
        :name, :phone, :address, :card_number, :id_card, :sex
      )
    end

    def param_page
      params[:page]
    end

end
