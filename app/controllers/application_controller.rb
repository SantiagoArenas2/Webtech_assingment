class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: cookies.signed[:acting_user_id]) || User.order(:id).first
  end

  def require_current_user
    return if current_user

    redirect_to root_path, alert: "Create a user before performing this action."
  end
end
