class AbsentsController < ApplicationController
  before_action :require_login
  def index
    get_data
    @absents = Absent.page param_page
    if params[:id].present?
      if params[:id].to_i == current_user.id
        @absents = @absents.where(user: current_user)
      end
    end

    if params[:search].present?
      @search = params[:search].downcase
      search = "%"+@search+"%"
      @users = @users.where("lower(name) like ?", search)
    end
  end

  def get_data
    url = URI.parse('http://localhost/getData.php')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    return if res.code != "200"
    datas = JSON.parse(res.body)
    datas.each_with_index do |data, index|
      next if data==datas.first || data==datas.last
      fingerprint_id = data["pin"]
      user = User.find_by(fingerprint: fingerprint_id)
      next if user.nil?
      check_type = data["status"]
      date_time = data["waktu"]
      absent = Absent.find_by("DATE(check_in) = ? AND user_id = ?", DateTime.now.to_date, user.id)
      absent = Absent.create user: user, check_in: date_time if absent.nil?
      if check_type == "0"
        absent.check_in = date_time
        work_hours = calculate_work_hour absent.check_in, absent.check_out
        absent.work_hour = work_hours
      elsif check_type == "1"
        absent.check_out = date_time
        work_hours = calculate_work_hour absent.check_in, absent.check_out
        absent.work_hour = work_hours
      elsif check_type == "2"
        absent.overtime_in = date_time
        work_hours = calculate_work_hour absent.check_in, absent.check_out
        absent.work_hour = work_hours
      elsif check_type == "3"
        absent.overtime_out = date_time
        work_hours = calculate_work_hour absent.check_in, absent.check_out
        absent.work_hour = work_hours
      end
      absent.save!
    end
  end

  def calculate_work_hour check_in, check_out
    return nil if check_out.nil?
    divide_hour = check_out.to_time - check_in.to_time
    raw_hour = divide_hour / 1.hour
    hour = raw_hour.to_i.to_s
    divide_min = raw_hour - raw_hour.to_i
    raw_min = divide_min*60
    minute = raw_min.to_i.to_s
    sec = ((raw_min - raw_min.to_i)*60).to_i.to_s
    return hour+":"+minute+":"+sec
  end

  private
  	def param_page
      params[:page]
    end
end