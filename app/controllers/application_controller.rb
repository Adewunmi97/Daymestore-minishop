class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :configure_permitted_parameters, if: :devise_controller?
  allow_browser versions: :modern

  helper_method :current_cart

  def current_cart
    @current_cart ||= current_user&.cart if user_signed_in?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :profile_photo])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :profile_photo])
  end
end
