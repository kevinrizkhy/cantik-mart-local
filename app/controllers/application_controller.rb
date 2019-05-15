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

  def redirect_back_no_access_right arg:nil
    redirect_back fallback_location: root_path, flash: { error: 'Tidak memiliki hak akses' }
  end

  def redirect_back_data_not_found current_path
    redirect_back fallback_location: current_path, flash: { error: 'Data tidak ditemukan' }
  end

  def redirect_back_data_invalid current_path
    redirect_back fallback_location: current_path, flash: { error: 'Data tidak valid' }
  end

end
