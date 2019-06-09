class UsersController < ApplicationController
  before_action :require_login
  before_action :require_fingerprint
  def index
    @users = User.page param_page
    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      @users = @users.where("lower(name) like ? OR phone like ?", search, search)
    end

  end

  def show
    return redirect_back_data_not_found users_path unless params[:id].present?
    @user = User.find_by_id params[:id]
    return redirect_back_data_not_found users_path unless @user.present?
  end

  def new
    @stores = Store.all
  end

  def create
    user = User.new user_params
    return redirect_back_data_not_found new_user_path if user.invalid?
    user.save!
    user.create_activity :create, owner: current_user
    return redirect_success users_path
  end

  def edit
    return redirect_back_data_not_found users_path unless params[:id].present?
    @user = User.find_by_id params[:id]
    @stores = Store.all
    return redirect_back_data_not_found users_path unless @user.present?
  end

  def update
    return redirect_back_data_not_found users_path unless params[:id].present?
    file = params[:user][:image]
    upload_io = params[:user][:image]
    if file.present?
      filename = Digest::SHA1.hexdigest([Time.now, rand].join).to_s+File.extname(file.path).to_s
      File.open(Rails.root.join('public', 'uploads', 'profile_picture', filename), 'wb') do |file|
        file.write(upload_io.read)
      end
    end
    user = User.find_by_id params[:id]
    user.image = filename
    user.assign_attributes user_params
    user.save! if user.changed?
<<<<<<< HEAD
    user.create_activity :create, owner: current_user
=======
    user.create_activity :edit, owner: current_user
>>>>>>> 8e2056969e4d407ad93d48ffa3e38012fb18c238
    return redirect_success users_path
  end

  private
    def user_params
      params.require(:user).permit(
        :name, :email, :password, :level, :phone, :sex, :store_id, :id_card, :address, :fingerprint
      )
    end

    def param_page
      params[:page]
    end
end
