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
    user = current_user
    absent = Absent.find_by("DATE(check_in) = ? AND user_id = ?", DateTime.now.to_date, user.id)
    redirect_to absents_path, flash: { error: 'Silakan untuk melakukan absensi terlebih dahulu' }
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

end
