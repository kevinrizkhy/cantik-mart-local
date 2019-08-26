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
    return redirect_back_data_error new_member_path, "Data Member - " + member.name + " - Tidak Valid" if member.invalid?
    member.save!
    member.create_activity :create, owner: current_user
    urls = member_path id: member.id
    return redirect_success urls, "Member - " + member.name + " - Berhasil Ditambahkan"
  end

  def edit
    return redirect_back_data_error members_path, "Data Member Tidak Ditemukan" unless params[:id].present?
    @member = Member.find_by_id params[:id]
    return redirect_back_data_error members_path, "Data Member Tidak Ditemukan" unless @member.present?
  end

  def update
    return redirect_back_data_error members_path, "Data Member Tidak Ditemukan" unless params[:id].present?
    member = Member.find_by_id params[:id]
    member.assign_attributes member_params
    member.name = params[:member][:name].camelize
    changes = member.changes
    member.save! if member.changed?
    member.create_activity :edit, owner: current_user, parameters: changes
    urls = member_path id: member.id
    return redirect_success urls, "Member - " + member.name + " - Berhasil Diubah"
  end

  def show
    return redirect_back_data_error members_path, "Data Member Tidak Ditemukan" unless params[:id].present?
    @member = Member.find_by_id params[:id]
    return redirect_back_data_error members_path, "Data Member Tidak Ditemukan" unless @member.present?
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
