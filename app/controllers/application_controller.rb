class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :phone, :birth_day])
    devise_parameter_sanitizer.permit(:account_update, keys: [:firstname, :lastname, :phone])
  end
end
