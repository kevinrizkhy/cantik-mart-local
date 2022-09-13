class ApplicationController < ActionController::Base
  include Clearance::Controller
  include PublicActivity::StoreController 
  before_action :screening

  @@last_post = nil
  @@last_update = nil

  protected
    def authorize *authorized_level
      redirect_back_no_access_right unless authorized_level.include? current_user.level
    end

    def not_authorize *level
      redirect_back_no_access_right if level.include? current_user.level
    end

    def validate_access_only methods
      return methods.include?(action_name.to_sym)
    end

    def screening
      @weather = {}

      url = "http://api.weatherapi.com/v1/current.json?key=e4a2290877b44fc79f5140927221109&q=-6.6413273,107.3890488&aqi=no"
      response = Net::HTTP.get(URI.parse(url))
      json_response = JSON.parse(response)
      if json_response["error"].nil?
        weather_data = json_response["current"]
        @weather["temp"] = weather_data["temp_c"]
        @weather["condition"] = weather_data["condition"]["text"]
        @weather["icon"] = weather_data["condition"]["icon"]
      end
    end

    def require_fingerprint
      # authorization
      # user = current_user
      # absent = Absent.find_by("DATE(check_in) = ? AND user_id = ?", DateTime.now.to_date, user.id)
      # redirect_to absents_path, flash: { error: 'Silakan untuk melakukan absensi terlebih dahulu' }
    end

    def redirect_back_no_access_right arg:nil
      redirect_to no_access_right_path
      # redirect_back fallback_location: root_path, flash: { error: 'Tidak memiliki hak akses' }
    end

    def redirect_back_data_error current_path, message
      redirect_back fallback_location: current_path, flash: { error: message }
    end

    def redirect_success current_path, message
      redirect_to current_path, flash: { success: message }
    end

    def authorization
      return if current_user.level == "owner" || current_user.level == "super_admin"
      extracted_path = Rails.application.routes.recognize_path(request.original_url)
      controller_name = extracted_path[:controller].to_sym
      method_name = extracted_path[:action].to_sym
      accessible = authentication controller_name, method_name
      redirect_to root_path, flash: { error: 'Tidak memiliki hak akses' } if !accessible
    end

    def authentication controller_name, method_name
      controller = Controller.find_by(name: controller_name.to_s)
      return true if ["notifications", "absents"].include? controller.name

      find_method = ControllerMethod.find_by(controller: controller, name: method_name.to_s)
      get_access = UserMethod.find_by(user_level: current_user.level, controller_method: find_method)
      return true if get_access.present?
      return false
    end

    def set_notification from_user, to_user, m_type, message, link
      Notification.create from_user: from_user, to_user: to_user, m_type: m_type,
        message: message, link: link, date_created: DateTime.now
    end



end
