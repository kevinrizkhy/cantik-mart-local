class ApplicationController < ActionController::Base
  include Clearance::Controller

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

  def require_fingerprint
    authorization
    # user = current_user
    # absent = Absent.find_by("DATE(check_in) = ? AND user_id = ?", DateTime.now.to_date, user.id)
    # redirect_to absents_path, flash: { error: 'Silakan untuk melakukan absensi terlebih dahulu' }
  end

  def redirect_back_no_access_right arg:nil
    redirect_back fallback_location: root_path, flash: { error: 'Tidak memiliki hak akses' }
  end

  def redirect_back_data_not_found current_path
    redirect_back fallback_location: current_path, flash: { error: 'Data tidak ditemukan' }
  end

  def redirect_back_data_invalid current_path
    redirect_back fallback_location: current_path, flash: { error: 'Data tidak valid' }
  end

  def redirect_success current_path
    redirect_to current_path, flash: { success: 'Data berhasil disimpan' }
  end

  def authorization
    extracted_path = Rails.application.routes.recognize_path(request.original_url)
    controller_name = extracted_path[:controller].to_sym
    method_name = extracted_path[:action].to_sym
    accessible = authentication controller_name, method_name
    redirect_to root_path, flash: { error: 'Tidak memiliki hak akses' }
  end

  def authentication controller_name, method_name
    # binding.pry
    return true if current_user.level == User::SUPER_ADMIN || current_user.level == User::OWNER
    
    get_access = access[controller_name][method_name]
    return true if get_access.nil?
    accesible = get_access.include? current_user.level
    return accesible
  end

end
